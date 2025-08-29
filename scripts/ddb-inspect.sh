#!/usr/bin/env bash
set -euo pipefail

ENDPOINT=${DDB_ENDPOINT:-http://127.0.0.1:8000}
TABLE_NAME=${TABLE_NAME:-UrlsTable}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if DynamoDB Local is running
check_dynamodb_local() {
    if ! curl -s "$ENDPOINT" > /dev/null 2>&1; then
        print_error "DynamoDB Local is not running at $ENDPOINT"
        echo "Start it with: npm run ddb:start"
        exit 1
    fi
    print_success "DynamoDB Local is running at $ENDPOINT"
}

# Function to list all tables
list_tables() {
    print_header "Listing Tables"
    aws dynamodb list-tables --endpoint-url "$ENDPOINT" --output table
}

# Function to describe the table
describe_table() {
    print_header "Table Description: $TABLE_NAME"
    aws dynamodb describe-table --table-name "$TABLE_NAME" --endpoint-url "$ENDPOINT" --output table
}

# Function to scan all items
scan_items() {
    print_header "Scanning All Items in $TABLE_NAME"
    aws dynamodb scan --table-name "$TABLE_NAME" --endpoint-url "$ENDPOINT" --output table
}

# Function to get a specific item by ID
get_item() {
    local id=${1:-"abc123"}
    print_header "Getting Item with ID: $id"
    aws dynamodb get-item \
        --table-name "$TABLE_NAME" \
        --key "{\"id\":{\"S\":\"$id\"}}" \
        --endpoint-url "$ENDPOINT" \
        --output table
}

# Function to query by URL using GSI
query_by_url() {
    local url=${1:-"https://example.com"}
    print_header "Querying by URL: $url"
    aws dynamodb query \
        --table-name "$TABLE_NAME" \
        --index-name "UrlIndex" \
        --key-condition-expression "#u = :url" \
        --expression-attribute-names '{"#u":"url"}' \
        --expression-attribute-values "{\":url\":{\"S\":\"$url\"}}" \
        --endpoint-url "$ENDPOINT" \
        --output table
}

# Function to show table statistics
show_stats() {
    print_header "Table Statistics: $TABLE_NAME"
    aws dynamodb describe-table --table-name "$TABLE_NAME" --endpoint-url "$ENDPOINT" --query 'TableDescription.{TableName:TableName,ItemCount:ItemCount,TableSizeBytes:TableSizeBytes,TableStatus:TableStatus}' --output table
}

# Function to show help
show_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  list              List all tables"
    echo "  describe          Describe the table structure"
    echo "  scan              Scan all items in the table"
    echo "  get [ID]          Get item by ID (default: abc123)"
    echo "  query [URL]       Query by URL using GSI (default: https://example.com)"
    echo "  stats             Show table statistics"
    echo "  all               Run all inspection commands"
    echo "  help              Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  DDB_ENDPOINT      DynamoDB endpoint (default: http://127.0.0.1:8000)"
    echo "  TABLE_NAME        Table name (default: UrlsTable)"
    echo ""
    echo "Examples:"
    echo "  $0 all                    # Run all inspections"
    echo "  $0 get goaws              # Get item with ID 'goaws'"
    echo "  $0 query https://aws.amazon.com  # Query by URL"
    echo "  $0 scan                   # Scan all items"
}

# Main script logic
main() {
    local command=${1:-"help"}
    
    case "$command" in
        "list")
            check_dynamodb_local
            list_tables
            ;;
        "describe")
            check_dynamodb_local
            describe_table
            ;;
        "scan")
            check_dynamodb_local
            scan_items
            ;;
        "get")
            check_dynamodb_local
            get_item "$2"
            ;;
        "query")
            check_dynamodb_local
            query_by_url "$2"
            ;;
        "stats")
            check_dynamodb_local
            show_stats
            ;;
        "all")
            check_dynamodb_local
            echo ""
            list_tables
            echo ""
            describe_table
            echo ""
            scan_items
            echo ""
            get_item "abc123"
            echo ""
            query_by_url "https://example.com"
            echo ""
            show_stats
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"
