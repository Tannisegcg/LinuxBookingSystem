#!/bin/bash

# ------------------------------------------------------------
# Arrays for reusable field staff_prompts
# ------------------------------------------------------------

staff_fields=(
    "Staff_ID"
    "Applicant_Name"
    "Faculty"
    "Contact_Number"
    "Email"
)
staff_prompts=(
    "Staff ID"
    "Applicant Name"
    "Faculty/Center (FAFB/FOCS/FOAS/FOET/FSSH/CPUS)"
    "Contact Number"
    "Email"
)

book_fields=(
    "Author"
    "Title"
    "ISBN"
    "Publisher"
    "Year"
    "Edition"
    "Source"
    "Price"
    "Branch"
    "Status"
)
book_prompts=(
    "Author"
    "Title"
    "ISBN"
    "Publisher"
    "Year (4 digits)"
    "Edition (optional)"
    "Source (URL, may contain colons)"
    "Price (RM)"
    "Branch/Campus (KL/PP/PH/SB/JH/PK)"
    "Status (Approved/Pending/Disapproved)"
)

# ------------------------------------------------------------
# Validation functions
# ------------------------------------------------------------

valid_faculty() {
    [[ "$1" =~ ^(FAFB|FOCS|FOAS|FOET|FSSH|CPUS)$ ]]
}

valid_branch() {
    [[ "$1" =~ ^(KL|PP|PH|SB|JH|PK)$ ]]
}

valid_status() {
    [[ "$1" =~ ^(Approved|Pending|Disapproved)$ ]]
}
not_empty() {
    [[ -n "$1" ]]
}

no_colon() {
    [[ "$1" != *:* ]]
}

is_numeric() {
    [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]
}

valid_date() {
    [[ "$1" =~ ^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$ ]]
}

valid_year() {
    [[ "$1" =~ ^[0-9]{4}$ ]]
}

bold() {
    echo -e "\033[1m$1\033[0m"
}

#bold=$(tput bold)
#normal=$(tput sgr0)

print_line() {
    local cols=${COLUMNS:-$(tput cols)}  # fallback if COLUMNS not set
    printf '%*s\n' "$cols" '' | tr ' ' '_'
}

# ------------------------------------------------------------
# Prerequisite files
# ------------------------------------------------------------

if [ ! -f staff.txt ]; then
    echo "Staff file does not exist. Creating staff.txt…"
    echo "Requisition_ID:Staff_ID:Applicant_Name:Faculty:Contact_Number:Email" >> staff.txt
fi

if [ ! -f requisition.txt ]; then
    echo "Book requisition file does not exist. Creating requisition.txt…"
    echo "Requisition_ID:Requisition_Date:Author:Title:ISBN:Publisher:Year:Edition:Source:Price:Branch:Status" >> requisition.txt
fi

# ------------------------------------------------------------
# Menu functions
# ------------------------------------------------------------

show_menu() {
    echo
    echo "Book Requisition Management System"
    echo "A – Add New Book Requisition Details"
    echo "U – Update Book Requisition Details"
    echo "D – Delete Book Requisition Details"
    echo "S - Search Book Requisition Details"
    echo "R – Sort Book Requisitions"
    echo "Q – Exit from Program"
    echo
}

add_requisition() {
    
    generate_next_id() {
        local last_id=$(tail -n1 requisition.txt 2>/dev/null | cut -d':' -f1)
        if [[ ! "$last_id" =~ ^R[0-9]{5}$ ]]; then
            echo "R00001"
        else
            local num=${last_id#R}
            num=$((10#$num + 1))
            printf "R%05d" "$num"
        fi
    }
    
    # input loop
    while true; do
        clear
        echo 
        echo -e "$(bold "Add New Book Requisition Details Form")"
        echo "========================"

        # Requisition_ID and Requisition_Date are auto-generated
        req_id=$(generate_next_id)
        req_date=$(date +"%-d-%-m-%Y")   # e.g., 5-4-2026 (no leading zeros)

        echo "Requisition ID (auto-generated): $req_id"
        echo "Requisition Date (auto): $req_date"
        echo
        echo -e "$(bold "Applicant Details:")"
        echo "========================"

        # Collect staff details
        declare -A staff_values
        for i in "${!staff_fields[@]}"; do
            field="${staff_fields[$i]}"
            prompt="${staff_prompts[$i]}"
            while true; do
                read -p "$prompt: " input
                case "$field" in
                    Staff_ID|Applicant_Name|Contact_Number|Email)
                        if not_empty "$input" && no_colon "$input"; then
                            break
                        else
                            echo "Error: $field cannot be empty and must not contain ':'." >&2
                        fi
                        ;;
                    Faculty)
                        input="${input^^}" # Double caret symbol for capitalization
                        if valid_faculty "$input"; then
                            break
                        else
                            echo "Error: Faculty must be one of FAFB, FOCS, FOAS, FOET, FSSH, CPUS." >&2
                        fi
                        ;;
                esac
            done
            staff_values["$field"]="$input"
        done

        echo
        echo -e "$(bold "Book Requisition Details:")"
        echo "============================"

        # Collect book details
        declare -A book_values
        for i in "${!book_fields[@]}"; do
            field="${book_fields[$i]}"
            prompt="${book_prompts[$i]}"
            while true; do
                read -p "$prompt: " input
                case "$field" in
                    Author|Title|Publisher)
                        if not_empty "$input" && no_colon "$input"; then
                            break
                        else
                            echo "Error: $field cannot be empty and must not contain ':'." >&2
                        fi
                        ;;
                    ISBN)
                        if not_empty "$input" && no_colon "$input"; then
                            break
                        else
                            echo "Error: ISBN cannot be empty and must not contain ':'." >&2
                        fi
                        ;;
                    Year)
                        if valid_year "$input"; then
                            break
                        else
                            echo "Error: Year must be a 4-digit number." >&2
                        fi
                        ;;
                    Edition)
                        if [[ -z "$input" ]] || no_colon "$input"; then
                            break
                        else
                            echo "Error: Edition must not contain ':'." >&2
                        fi
                        ;;
                    Source)
                        if not_empty "$input"; then
                            break
                        else
                            echo "Error: Source cannot be empty." >&2
                        fi
                        ;;
                    Price)
                        if is_numeric "$input"; then
                            break
                        else
                            echo "Error: Price must be a number." >&2
                        fi
                        ;;
                    Branch)
                        input="${input^^}"
                        if valid_branch "$input"; then
                            break
                        else
                            echo "Error: Branch must be KL, PP, PH, SB, JH, or PK." >&2
                        fi
                        ;;
                    Status)
                        # Capitalize first letter
                        input="${input^}"
                        if valid_status "$input"; then
                            break
                        else
                            echo "Error: Status must be Approved, Pending, or Disapproved." >&2
                        fi
                        ;;
                esac
            done
            book_values["$field"]="$input"
        done

        # Append to staff.txt
        staff_line="$req_id:${staff_values[Staff_ID]}:${staff_values[Applicant_Name]}:${staff_values[Faculty]}:${staff_values[Contact_Number]}:${staff_values[Email]}"
        echo "$staff_line" >> staff.txt

        # Append to requisition.txt
        req_line="$req_id:$req_date:${book_values[Author]}:${book_values[Title]}:${book_values[ISBN]}:${book_values[Publisher]}:${book_values[Year]}:${book_values[Edition]}:${book_values[Source]}:${book_values[Price]}:${book_values[Branch]}:${book_values[Status]}"
        echo "$req_line" >> requisition.txt

        echo
        echo "Requisition record added successfully (ID: $req_id)."

        # Add another, double comma converts to lowercase
        print_line
        read -p "Add another new requisition details? (y)es or (q)uit : " another
        case "${another,,}" in
            y) continue ;;
            q) break ;;
            *) echo "Invalid. Returning to menu."; break ;;
        esac
    done

    read -p "Press Enter to continue..."
}

update_requisition() {
    echo "Update feature not implemented yet."
    read -p "Press Enter to continue..."
}

delete_requisition() {
    echo "Delete feature not implemented yet."
    read -p "Press Enter to continue..."
}

search_requisition() {
    echo "Search feature not implemented yet."
    read -p "Press Enter to continue..."
}

sort_requisitions() {
    echo "Sort feature not implemented yet."
    read -p "Press Enter to continue..."
}

exit_program() {
    echo "Exiting program."
    exit 0
}

# ------------------------------------------------------------
# Main loop
# ------------------------------------------------------------

while true; do
    show_menu
    read -p "Please select a choice: " choiceStart

    case "${choiceStart,,}" in
        a) add_requisition ;;
        u) update_requisition ;;
        d) delete_requisition ;;
        s) search_requisition ;;
        r) sort_requisitions ;;
        q) exit_program ;;
        *)
            echo "Invalid choice. Please enter A, U, D, S, R, or Q."
            read -p "Press Enter to continue..."
            ;;
    esac
    clear
done