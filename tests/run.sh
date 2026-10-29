#!/usr/bin/env bash
# Testes de fumaça sem aparelho: usam tests/adb para simular um Galaxy One UI 9.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$ROOT/tests:$PATH"
export FAKE_ADB_STATE="$(mktemp -d "${TMPDIR:-/tmp}/fake-adb.XXXXXX")"
export SCSUNG_DATA_DIR="$(mktemp -d "${TMPDIR:-/tmp}/scamsung-data.XXXXXX")"
export NO_COLOR=1

FAILS=0
CHECKS=0

sc() { /bin/bash "$ROOT/scamsung" "$@"; }

pass() { CHECKS=$((CHECKS + 1)); printf '  ok   %s\n' "$1"; }
fail() { CHECKS=$((CHECKS + 1)); FAILS=$((FAILS + 1)); printf '  FAIL %s\n' "$1"; }

assert_contains() {
    local desc="$1" haystack="$2" needle="$3"
    case "$haystack" in
        *"$needle"*) pass "$desc" ;;
        *) fail "$desc (faltou: $needle)"; printf '%s\n' "$haystack" | sed 's/^/       /' ;;
    esac
}

assert_not_contains() {
    local desc="$1" haystack="$2" needle="$3"
    case "$haystack" in
        *"$needle"*) fail "$desc (não deveria conter: $needle)" ;;
        *) pass "$desc" ;;
    esac
}

assert_file_has() {
    local desc="$1" file="$2" needle="$3"
    if [ -f "$file" ] && grep -Fxq "$needle" "$file"; then
        pass "$desc"
    else
        fail "$desc (faltou $needle em $file)"
    fi
}

assert_file_lacks() {
    local desc="$1" file="$2" needle="$3"
    if [ -f "$file" ] && grep -Fxq "$needle" "$file"; then
        fail "$desc (ainda presente: $needle)"
    else
        pass "$desc"
    fi
}

printf '\n== self-test ==\n'
out="$(sc self-test 2>&1)"; rc=$?
[ "$rc" -eq 0 ] && pass "self-test exit 0" || fail "self-test exit $rc"
assert_contains "presets ok" "$out" "presets ok"

printf '\n== doctor ==\n'
out="$(sc doctor 2>&1)"; rc=$?
assert_contains "doctor detecta aparelho" "$out" "SM-S931B (e1q)"
assert_contains "doctor lê One UI 9.0" "$out" "One UI 9.0"
assert_contains "doctor lê Android 17" "$out" "Android 17"

printf '\n== scan ==\n'
out="$(sc scan 2>&1)"
assert_contains "scan acha facebook" "$out" "com.facebook.appmanager"
assert_contains "scan marca pacote de lista" "$out" "[na lista]"
if printf '%s\n' "$out" | grep -q 'com.google.android.gms.*\[protegido\]'; then
    pass "scan marca pacote protegido"
else
    fail "scan marca pacote protegido"
fi

printf '\n== prévia obrigatória ==\n'
out="$(sc --only com.facebook.katana apply </dev/null 2>&1)"
assert_contains "prévia marca o pacote" "$out" "~ com.facebook.katana  — Facebook"
assert_contains "prévia conta pacotes" "$out" "remover:"
assert_contains "pede confirmação" "$out" "Digite"
if [ -f "$SCSUNG_DATA_DIR/state.tsv" ]; then
    fail "sem 'sim' não deveria gravar estado"
else
    pass "sem 'sim' não grava estado"
fi
assert_file_has "sem 'sim' não altera aparelho" "$FAKE_ADB_STATE/installed.txt" "com.facebook.katana"

printf '\n== apply --only ==\n'
out="$(sc -y apply --only com.samsung.android.rubin.app 2>&1)"
assert_contains "remove rubin.app" "$out" "+ com.samsung.android.rubin.app"
assert_contains "apply mostra o que é o pacote" "$out" "Customization Service (perfil de personalização)"
assert_file_has "rubin.app saiu do aparelho" "$FAKE_ADB_STATE/removed.txt" "com.samsung.android.rubin.app"
assert_contains "estado registrado" "$(cat "$SCSUNG_DATA_DIR/state.tsv" 2>/dev/null)" "REMOVED"

printf '\n== apply basic ==\n'
out="$(sc -y apply basic 2>&1)"
assert_file_has "facebook removido" "$FAKE_ADB_STATE/removed.txt" "com.facebook.katana"
assert_file_has "netflix removido" "$FAKE_ADB_STATE/removed.txt" "com.netflix.mediaclient"
assert_file_has "aremoji removido" "$FAKE_ADB_STATE/removed.txt" "com.samsung.android.aremoji"
assert_file_lacks "GMS preservado" "$FAKE_ADB_STATE/removed.txt" "com.google.android.gms"
assert_file_lacks "Play Store preservado" "$FAKE_ADB_STATE/removed.txt" "com.android.vending"
assert_file_lacks "teclado preservado" "$FAKE_ADB_STATE/removed.txt" "com.samsung.android.honeyboard"
assert_file_lacks "AOD preservado" "$FAKE_ADB_STATE/removed.txt" "com.samsung.android.app.aodservice"
assert_file_lacks "soundpicker preservado" "$FAKE_ADB_STATE/removed.txt" "com.samsung.android.app.soundpicker"
assert_contains "resumo de removidos" "$out" "removidos:"

printf '\n== deny-list ==\n'
out="$(sc -y --only com.google.android.gms apply 2>&1)"
assert_contains "GMS bloqueado" "$out" "bloqueado pela política"
assert_file_lacks "GMS não foi tocado" "$FAKE_ADB_STATE/removed.txt" "com.google.android.gms"

out="$(sc -y --only com.samsung.android.timezone.autoupdate_O,com.samsung.android.kgclient apply 2>&1)"
assert_contains "timezone bloqueado" "$out" "com.samsung.android.timezone.autoupdate_O"
assert_contains "kgclient bloqueado" "$out" "com.samsung.android.kgclient"
assert_file_lacks "timezone intacto" "$FAKE_ADB_STATE/removed.txt" "com.samsung.android.timezone.autoupdate_O"
assert_file_lacks "kgclient intacto" "$FAKE_ADB_STATE/removed.txt" "com.samsung.android.kgclient"

printf '\n== pacote inexistente ==\n'
out="$(sc -y --only com.does.not.exist apply 2>&1)"
assert_contains "inexistente é contado, não é erro" "$out" "ausentes no aparelho: 1 (ignorados)"
assert_contains "inexistente não aplica nada" "$out" "nada a fazer"

printf '\n== restore ==\n'
sc -y restore >/dev/null 2>&1
if [ -s "$SCSUNG_DATA_DIR/state.tsv" ]; then
    fail "estado deveria estar vazio após restore ($(wc -l < "$SCSUNG_DATA_DIR/state.tsv") linhas)"
else
    pass "estado vazio após restore"
fi
assert_file_has "facebook reinstalado" "$FAKE_ADB_STATE/installed.txt" "com.facebook.katana"
assert_file_has "aremoji reinstalado" "$FAKE_ADB_STATE/installed.txt" "com.samsung.android.aremoji"
assert_file_lacks "nada pendente em removed" "$FAKE_ADB_STATE/removed.txt" "com.facebook.katana"

printf '\n== modo disable + restore ==\n'
out="$(sc -y --disable --only com.samsung.android.game.gos apply 2>&1)"
assert_contains "gos desativado" "$out" "(desativado)"
assert_file_has "gos em disabled" "$FAKE_ADB_STATE/disabled.txt" "com.samsung.android.game.gos"
assert_contains "estado DISABLED" "$(cat "$SCSUNG_DATA_DIR/state.tsv" 2>/dev/null)" "DISABLED"
sc -y restore >/dev/null 2>&1
assert_file_lacks "gos reativado" "$FAKE_ADB_STATE/disabled.txt" "com.samsung.android.game.gos"
assert_file_has "gos de volta em installed" "$FAKE_ADB_STATE/installed.txt" "com.samsung.android.game.gos"

printf '\n== skip ==\n'
out="$(sc -y --skip com.samsung.android.arzone apply basic 2>&1)"
assert_file_has "basic aplicado depois do restore" "$FAKE_ADB_STATE/removed.txt" "com.samsung.android.aremoji"
assert_file_lacks "--skip respeitado" "$FAKE_ADB_STATE/removed.txt" "com.samsung.android.arzone"

# o basic remove o GOS (itxjobe); reativa no fake para o bloco de tweaks
adb shell pm enable com.samsung.android.game.gos >/dev/null 2>&1

printf '\n== --categories foi removido ==\n'
out="$(sc --categories social apply 2>&1)"
assert_contains "avisa que --categories saiu" "$out" "--categories não existe mais"

printf '\n== tweaks ==\n'
out="$(sc tweaks --status 2>&1)"
assert_contains "status vazio no início" "$out" "nenhum"

out="$(sc -y tweaks 2>&1)"
assert_contains "chave ausente é pulada" "$out" "não existe neste firmware"
assert_contains "resumo conta pulados" "$out" "pulados:"
assert_contains "animação 0.5x" "$(cat "$FAKE_ADB_STATE/settings.txt" 2>/dev/null)" "window_animation_scale 0.5"
assert_contains "bateria adaptativa ligada" "$(cat "$FAKE_ADB_STATE/settings.txt" 2>/dev/null)" "adaptive_battery_management_enabled 1"
assert_contains "registro guarda original" "$(cat "$SCSUNG_DATA_DIR/tweaks.tsv" 2>/dev/null)" "window_animation_scale"
out="$(sc tweaks --status 2>&1)"
assert_contains "status lista o ajuste" "$out" "window_animation_scale"

out="$(sc -y tweaks 2>&1)"
assert_contains "segunda aplicação é idempotente" "$out" "já está em 0.5"

sc -y tweaks --reset >/dev/null 2>&1
assert_contains "reset apaga a chave" "$(cat "$FAKE_ADB_STATE/settings.txt" 2>/dev/null)" "delete global window_animation_scale"
assert_not_contains "valor não ficou para trás" "$(cat "$FAKE_ADB_STATE/settings-db.txt" 2>/dev/null)" "window_animation_scale"
out="$(sc tweaks --reset 2>&1)"
assert_contains "reset sem registro avisa" "$out" "nada para reverter"

out="$(sc -y tweaks --ram-plus off 2>&1)"
assert_contains "ram-plus ausente é avisado" "$out" "não expõe 'ram_expand_size'"

printf '\n== tweaks --performance ==\n'
printf 'ram_expand_size=2048\n' >> "$FAKE_ADB_STATE/settings-db.txt"
out="$(sc -y tweaks --performance 2>&1)"
assert_contains "performance desativa GOS" "$out" "pacote desativado: com.samsung.android.game.gos"
assert_file_has "GOS em disabled" "$FAKE_ADB_STATE/disabled.txt" "com.samsung.android.game.gos"
assert_contains "performance usa 0.35x" "$(cat "$FAKE_ADB_STATE/settings.txt" 2>/dev/null)" "window_animation_scale 0.35"
assert_contains "performance desliga RAM Plus" "$(cat "$FAKE_ADB_STATE/settings.txt" 2>/dev/null)" "ram_expand_size 0"
out="$(sc tweaks --status 2>&1)"
assert_contains "status mostra pacote desativado" "$out" "com.samsung.android.game.gos"

sc -y tweaks --reset >/dev/null 2>&1
assert_file_lacks "reset reativa GOS" "$FAKE_ADB_STATE/disabled.txt" "com.samsung.android.game.gos"
assert_contains "reset devolve RAM Plus" "$(cat "$FAKE_ADB_STATE/settings-db.txt" 2>/dev/null)" "ram_expand_size=2048"

printf '\n----------------------------------------\n'
if [ "$FAILS" -eq 0 ]; then
    printf 'TODOS OS TESTES PASSARAM (%s verificações)\n' "$CHECKS"
    exit 0
fi
printf 'FALHAS: %s de %s verificações\n' "$FAILS" "$CHECKS"
exit 1
