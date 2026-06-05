#!/usr/bin/env bash
# ============================================================
#  transaction_logger.sh
#  Day 1 — Fintech Bash Scripting Streak
#  Purpose: Record financial transactions into a structured CSV
# ============================================================

set -euo pipefail

# ── Configuration ────────────────────────────────────────────
DATA_DIR="$HOME/fintech_toolkit/data"
LOG_FILE="$DATA_DIR/transactions.csv"
DATE_FMT="%Y-%m-%d %H:%M:%S"

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Helpers ──────────────────────────────────────────────────
log_info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
log_success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

# ── Setup ────────────────────────────────────────────────────
setup_environment() {
    mkdir -p "$DATA_DIR"

    # Write CSV header only if the file doesn't exist yet
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "transaction_id,timestamp,type,amount,description,status" > "$LOG_FILE"
        log_info "Created new transaction log: $LOG_FILE"
    fi
}

# ── Generate a unique transaction ID ─────────────────────────
generate_txn_id() {
    # Format: TXN-YYYYMMDD-XXXXXX  (6 random hex chars)
    local date_part
    date_part=$(date +%Y%m%d)
    local rand_part
    rand_part=$(head -c 3 /dev/urandom | xxd -p | tr '[:lower:]' '[:upper:]')
    echo "TXN-${date_part}-${rand_part}"
}

# ── Validate amount (positive number, up to 2 decimal places) ─
validate_amount() {
    local amount="$1"
    if [[ ! "$amount" =~ ^[0-9]+(\.[0-9]{1,2})?$ ]]; then
        log_error "Invalid amount: '$amount'. Enter a positive number (e.g. 1500 or 99.99)."
        return 1
    fi
    return 0
}

# ── Validate transaction type ─────────────────────────────────
validate_type() {
    local type="$1"
    if [[ "$type" != "credit" && "$type" != "debit" ]]; then
        log_error "Invalid type: '$type'. Must be 'credit' or 'debit'."
        return 1
    fi
    return 0
}

# ── Sanitize description (strip commas to protect CSV format) ─
sanitize_description() {
    echo "$1" | tr -d ','
}

# ── Log a single transaction ──────────────────────────────────
log_transaction() {
    local txn_id timestamp type amount description status="SUCCESS"

    txn_id=$(generate_txn_id)
    timestamp=$(date +"$DATE_FMT")

    echo ""
    echo -e "${BOLD}━━━  New Transaction  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # ── Amount ────────────────────────────────────────────────
    while true; do
        read -rp "  Amount (e.g. 5000 or 250.75): " amount
        if validate_amount "$amount"; then break; fi
    done

    # ── Type ──────────────────────────────────────────────────
    while true; do
        read -rp "  Type (credit/debit): " type
        type="${type,,}"   # lowercase
        if validate_type "$type"; then break; fi
    done

    # ── Description ───────────────────────────────────────────
    read -rp "  Description: " description
    description=$(sanitize_description "$description")
    if [[ -z "$description" ]]; then
        description="No description"
    fi

    # ── Write to CSV ──────────────────────────────────────────
    echo "${txn_id},${timestamp},${type},${amount},${description},${status}" >> "$LOG_FILE"

    echo ""
    echo -e "${BOLD}  Transaction Recorded${RESET}"
    echo -e "  ┌─────────────────────────────────────────────"
    echo -e "  │  ID         : ${CYAN}${txn_id}${RESET}"
    echo -e "  │  Timestamp  : ${timestamp}"
    echo -e "  │  Type       : $(type_color "$type")${type}${RESET}"
    echo -e "  │  Amount     : \$${amount}"
    echo -e "  │  Description: ${description}"
    echo -e "  │  Status     : ${GREEN}${status}${RESET}"
    echo -e "  └─────────────────────────────────────────────"
    echo ""
}

# ── Color helper for type ─────────────────────────────────────
type_color() {
    if [[ "$1" == "credit" ]]; then echo -n "$GREEN"; else echo -n "$RED"; fi
}

# ── Display recent transactions ───────────────────────────────
show_recent() {
    local n="${1:-5}"
    echo ""
    echo -e "${BOLD}━━━  Last ${n} Transactions  ━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    if [[ ! -f "$LOG_FILE" ]] || [[ $(wc -l < "$LOG_FILE") -le 1 ]]; then
        log_warn "No transactions recorded yet."
        return
    fi

    # Print header
    printf "  %-22s %-10s %-10s %-10s %s\n" "ID" "TIME" "TYPE" "AMOUNT" "DESCRIPTION"
    printf "  %s\n" "──────────────────────────────────────────────────────────────"

    # Skip CSV header, grab last n lines
    tail -n +"2" "$LOG_FILE" | tail -n "$n" | while IFS=',' read -r id ts type amount desc status; do
        local short_ts="${ts:11:8}"   # HH:MM:SS portion
        printf "  %-22s %-10s %-10s \$%-9s %s\n" "$id" "$short_ts" "$type" "$amount" "$desc"
    done
    echo ""
}

# ── Show quick stats ──────────────────────────────────────────
show_stats() {
    if [[ ! -f "$LOG_FILE" ]] || [[ $(wc -l < "$LOG_FILE") -le 1 ]]; then
        return
    fi

    local total credits debits
    total=$(( $(wc -l < "$LOG_FILE") - 1 ))
    credits=$(grep -c ",credit," "$LOG_FILE" 2>/dev/null || echo 0)
    debits=$(grep  -c ",debit,"  "$LOG_FILE" 2>/dev/null || echo 0)

    echo -e "${BOLD}━━━  Ledger Stats  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  Total transactions : ${BOLD}${total}${RESET}"
    echo -e "  Credits            : ${GREEN}${credits}${RESET}"
    echo -e "  Debits             : ${RED}${debits}${RESET}"
    echo -e "  Log file           : ${LOG_FILE}"
    echo ""
}

# ── Interactive menu ──────────────────────────────────────────
main_menu() {
    while true; do
        echo -e "${BOLD}━━━  Fintech Transaction Logger  ━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo "  [1] Log a new transaction"
        echo "  [2] View recent transactions"
        echo "  [3] View ledger stats"
        echo "  [4] Exit"
        echo ""
        read -rp "  Select an option [1-4]: " choice
        echo ""

        case "$choice" in
            1) log_transaction ;;
            2)
                read -rp "  How many recent entries to show? [default: 5]: " n
                show_recent "${n:-5}"
                ;;
            3) show_stats ;;
            4)
                log_info "Exiting Transaction Logger. Goodbye!"
                break
                ;;
            *)
                log_warn "Invalid option. Please enter 1, 2, 3, or 4."
                echo ""
                ;;
        esac
    done
}

# ── Entry point ───────────────────────────────────────────────
setup_environment
echo ""
echo -e "${BOLD}${CYAN}  ███████╗██╗███╗   ██╗████████╗███████╗ ██████╗██╗  ██╗${RESET}"
echo -e "${BOLD}${CYAN}  ██╔════╝██║████╗  ██║╚══██╔══╝██╔════╝██╔════╝██║  ██║${RESET}"
echo -e "${BOLD}${CYAN}  █████╗  ██║██╔██╗ ██║   ██║   █████╗  ██║     ███████║${RESET}"
echo -e "${BOLD}${CYAN}  ██╔══╝  ██║██║╚██╗██║   ██║   ██╔══╝  ██║     ██╔══██║${RESET}"
echo -e "${BOLD}${CYAN}  ██║     ██║██║ ╚████║   ██║   ███████╗╚██████╗██║  ██║${RESET}"
echo -e "${BOLD}${CYAN}  ╚═╝     ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝${RESET}"
echo -e "         ${BOLD}Transaction Logger  •  Day 1${RESET}"
echo ""
show_stats
main_menu
