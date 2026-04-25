#!/bin/bash

# ============================================
# Book Requisition Management System
# BMCS2093 Operating Systems Practical Assignment
# ============================================

# Data files
STAFF_FILE="staff.txt"
REQ_FILE="requisition.txt"

# ============================================
# UTILITY FUNCTIONS
# ============================================

# Initialize files if they don't exist
initialize_files() {
    if [ ! -f "$STAFF_FILE" ]; then
        touch "$STAFF_FILE"
    fi
    if [ ! -f "$REQ_FILE" ]; then
        touch "$REQ_FILE"
    fi
}

# Generate next Requisition ID
generate_req_id() {
    if [ ! -s "$REQ_FILE" ]; then
        echo "R00001"
    else
        last_id=$(grep -v '^$' "$REQ_FILE" | tail -1 | cut -d':' -f1)
        num=$(echo "$last_id" | sed 's/R//')
        next_num=$((10#$num + 1))
        printf "R%05d" "$next_num"
    fi
}

# Get current date in format dd-mm-yyyy
get_current_date() {
    date +"%d-%m-%Y"
}

# Helper function to parse requisition line with awk (handles URLs containing :)
parse_req_line() {
    local line="$1"
    awk -F':' '{
        print $1;       # req_id
        print $2;       # req_date
        print $3;       # author
        print $4;       # title
        print $5;       # isbn
        print $6;       # publisher
        print $7;       # year
        print $8;       # edition
        # Reconstruct source: fields 9 to NF-3 (everything between edition and price)
        source = $9;
        for(i=10; i<=NF-3; i++) source = source ":" $i;
        print source;   # source (with original colons restored)
        print $(NF-2);  # price
        print $(NF-1);  # branch
        print $NF       # status
    }' <<< "$line"
}

print_row_faculty() {
   local r_id="$1" r_author="$2" r_title="$3" r_pub="$4" r_status="$5" r_date="$6"
   local pub_width=30
   printf "%-14.14s %-24.24s %-30.30s %-30.30s %-12.12s %-16.16s\n" \
       "$r_id" "$r_author" "$r_title" "${r_pub:0:$pub_width}" "$r_status" "$r_date"
   local remainder="${r_pub:$pub_width}"
   while [ -n "$remainder" ]; do
       printf "%-14.14s %-24.24s %-30.30s %-30.30s %-12.12s %-16.16s\n" \
           "" "" "" "${remainder:0:$pub_width}" "" ""
       remainder="${remainder:$pub_width}"
   done
}

print_row_status() {
   local r_id="$1" r_date="$2" r_fac="$3" r_campus="$4" r_author="$5" r_title="$6" r_pub="$7"
   local pub_width=24
   printf "%-14.14s %-16.16s %-8.8s %-8.8s %-24.24s %-30.30s %-24s\n" \
       "$r_id" "$r_date" "$r_fac" "$r_campus" "$r_author" "$r_title" "${r_pub:0:$pub_width}"
   local remainder="${r_pub:$pub_width}"
   while [ -n "$remainder" ]; do
       printf "%-14.14s %-16.16s %-8.8s %-8.8s %-24.24s %-30.30s %-24s\n" \
           "" "" "" "" "" "" "${remainder:0:$pub_width}"
       remainder="${remainder:$pub_width}"
   done
}

print_row_date() {
   local r_id="$1" r_fac="$2" r_campus="$3" r_author="$4" r_title="$5" r_pub="$6" r_status="$7"
   local pub_width=24
   printf "%-14.14s %-8.8s %-8.8s %-24.24s %-30.30s %-24s %-12.12s\n" \
       "$r_id" "$r_fac" "$r_campus" "$r_author" "$r_title" "${r_pub:0:$pub_width}" "$r_status"
   local remainder="${r_pub:$pub_width}"
   while [ -n "$remainder" ]; do
       printf "%-14.14s %-8.8s %-8.8s %-24.24s %-30.30s %-24s %-12.12s\n" \
           "" "" "" "" "" "${remainder:0:$pub_width}" ""
       remainder="${remainder:$pub_width}"
   done
}

# ============================================
# TASK 1: Main Menu
# ============================================
main_menu() {
    while true; do
        clear
        echo "Book Requisition Management System"
        echo
        echo "A – Add New Book Requisition Details"
        echo "U – Update Book Requisition Details"
        echo "D – Delete Book Requisition Details"
        echo "S – Search Book Requisition Details"
        echo "R – Sort Book Requisitions"
        echo "Q – Exit from Program"
        echo
        echo -n "Please select a choice: "

        read choice

        case "$choice" in
            [Aa])
                add_new_requisition
                ;;
            [Uu])
                update_requisition
                ;;
            [Dd])
                delete_requisition
                ;;
            [Ss])
                search_requisition
                ;;
            [Rr])
                sort_requisitions
                ;;
            [Qq])
                echo "Exiting program..."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                echo -n "Press Enter to continue..."
                read
                ;;
        esac
    done
}

# ============================================
# TASK 2: Add New Book Requisition Details
# ============================================
add_new_requisition() {
    while true; do
        clear
        echo "Add New Book Requisition Details Form"
        echo "========================"

        # Auto-generate Requisition ID
        req_id=$(generate_req_id)
        req_date=$(get_current_date)

        echo "Requisition ID (auto-generate): $req_id"
        echo "Requisition Date: $req_date"
        echo
        echo "Applicant Details:"
        echo "Staff ID: "
        echo "Applicant Name: "
        echo "Faculty/Center (FAFB/FOCS/FOAS/FOET/FSSH/CPUS): "
        echo "Contact Number: "
        echo "Email: "
        echo
        echo "Book Requisition Details:"
        echo "Author: "
        echo "Title: "
        echo "ISBN: "
        echo "Publisher: "
        echo "Year: "
        echo "Edition: "
        echo "Source: "
        echo "Price (RM): "
        echo "Branch/Campus (KL/PP/PH/SB/JH/PK): "
        echo "Status (Approved/Pending/Disapproved): Pending"
        echo
        echo "Press (q) Return to the Book Requisition Management System Menu."
        echo -n "Add another new requisition details? (y)es or (q)uit : "

        read choice

        case "$choice" in
            [Yy])
                clear
                echo "Add New Book Requisition Details Form"
                echo "========================"
                echo
                echo "Requisition ID (auto-generate): $req_id"
                echo "Requisition Date: $req_date"
                echo

                # Staff ID - exactly 4 digits
                while true; do
                    echo -n "Staff ID (4 digits): "
                    read staff_id
                    if [[ "$staff_id" =~ ^[0-9]{4}$ ]]; then
                        break
                    else
                        echo "Invalid input! Type 4 digits Only!"
                    fi
                done

                # Applicant Name - letters and spaces only, no numbers
                while true; do
                    echo -n "Applicant Name: "
                    read applicant_name
                    if [[ "$applicant_name" =~ ^[a-zA-Z\ ]+$ ]] && [[ ! "$applicant_name" =~ [0-9] ]]; then
                        break
                    else
                        echo "Invalid input! No numbers, letters only!"
                    fi
                done

                # Faculty - only specific options
                while true; do
                    echo -n "Faculty/Center (FAFB/FOCS/FOAS/FOET/FSSH/CPUS): "
                    read faculty
                    faculty_upper=$(echo "$faculty" | tr '[:lower:]' '[:upper:]')
                    if [[ "$faculty_upper" =~ ^(FAFB|FOCS|FOAS|FOET|FSSH|CPUS)$ ]]; then
                        faculty="$faculty_upper"
                        break
                    else
                        echo "Invalid input! Choose within the listed options!"
                    fi
                done

                # Contact Number - starts with 0, allows optional hyphen after prefix
                # Accepts formats: 0123456789, 01234567890, 012-3456789, 012-34567890
                while true; do
                    echo -n "Contact Number (e.g. 012-3456789): "
                    read contact
                    if [[ "$contact" =~ ^0[0-9]{1,2}-[0-9]{7,8}$ ]] || [[ "$contact" =~ ^0[0-9]{9,10}$ ]]; then
                        break
                    else
                        echo "Invalid input! Enter a valid Malaysian number (e.g. 012-3456789 or 0123456789)!"
                    fi
                done

                # Email - must have @ and domain extension
                while true; do
                    echo -n "Email: "
                    read email
                    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] && [[ ! "$email" =~ ^@ ]]; then
                        break
                    else
                        echo "Invalid input! Must have @ and domain extension (.com, .edu, etc.)!"
                    fi
                done

                echo
                echo "Book Requisition Details:"

                # Author - letters, spaces and dots only, no digits
                while true; do
                    echo -n "Author: "
                    read author
                    if [[ "$author" =~ ^[a-zA-Z\.\ ]+$ ]] && [[ ! "$author" =~ [0-9] ]]; then
                        break
                    else
                        echo "Invalid input! Letters and spaces only, no digits!"
                    fi
                done

                # Title - letters and spaces only
                while true; do
                    echo -n "Title: "
                    read title
                    if [[ "$title" =~ ^[a-zA-Z\ ]+$ ]] && [[ "$title" =~ [a-zA-Z] ]]; then
                        break
                    else
                        echo "Invalid input! Letters and spaces only, no numbers or special characters!"
                    fi
                done

                # ISBN - digits only, 10-13 characters
                while true; do
                    echo -n "ISBN: "
                    read isbn
                    if [[ "$isbn" =~ ^[0-9]{10,13}$ ]]; then
                        break
                    else
                        echo "Invalid input! Digits only within the range of 10-13 digits!"
                    fi
                done

                # Publisher - letters and spaces only, no digits
                while true; do
                    echo -n "Publisher: "
                    read publisher
                    if [[ "$publisher" =~ ^[a-zA-Z\ ]+$ ]] && [[ ! "$publisher" =~ [0-9] ]]; then
                        break
                    else
                        echo "Invalid input! Letters and spaces only, no digits!"
                    fi
                done

                # Year - 4 digits, 1900 to current year
                current_year=$(date +%Y)
                while true; do
                    echo -n "Year: "
                    read year
                    if [[ "$year" =~ ^[0-9]{4}$ ]] && [ "$year" -ge 1900 ] && [ "$year" -le "$current_year" ]; then
                        break
                    else
                        echo "Invalid input! Only 4 digits and range from 1900 to current year ($current_year)!"
                    fi
                done

                # Edition - 1-3 digits
                while true; do
                    echo -n "Edition: "
                    read edition
                    if [[ "$edition" =~ ^[0-9]{1,3}$ ]] && [ "$edition" -ge 1 ]; then
                        break
                    else
                        echo "Invalid input! 1-3 digits only, must be at least 1!"
                    fi
                done

                # Source - must be URL format (starts with http or https)
                while true; do
                    echo -n "Source (e.g. https://docs.google.com): "
                    read source
                    if [[ "$source" =~ ^https?://.+ ]]; then
                        break
                    else
                        echo "Invalid input! Must be URL format (e.g. https://example.com)!"
                    fi
                done

                # Price - positive number, cannot start with decimal point
                while true; do
                    echo -n "Price (RM): "
                    read price
                    if [[ "$price" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [[ ! "$price" =~ ^\. ]]; then
                        break
                    else
                        echo "Invalid input! Price must be a positive number (e.g. 99.90)!"
                    fi
                done

                # Branch/Campus - only specific options
                while true; do
                    echo -n "Branch/Campus (KL/PP/PH/SB/JH/PK): "
                    read branch
                    branch_upper=$(echo "$branch" | tr '[:lower:]' '[:upper:]')
                    if [[ "$branch_upper" =~ ^(KL|PP|PH|SB|JH|PK)$ ]]; then
                        branch="$branch_upper"
                        break
                    else
                        echo "Invalid input! Choose within the listed options!"
                    fi
                done

                # Status - only specific options (case insensitive, auto-capitalize)
                while true; do
                    echo -n "Status (Approved/Pending/Disapproved): "
                    read status_input
                    status_lower=$(echo "$status_input" | tr '[:upper:]' '[:lower:]')
                    case "$status_lower" in
                        approved)
                            status="Approved"
                            break
                            ;;
                        pending)
                            status="Pending"
                            break
                            ;;
                        disapproved)
                            status="Disapproved"
                            break
                            ;;
                        *)
                            echo "Invalid input! Choose within the listed options!"
                            ;;
                    esac
                done

                # Save data to files
                echo "${req_id}:${staff_id}:${applicant_name}:${faculty}:${contact}:${email}" >> "$STAFF_FILE"
                echo "${req_id}:${req_date}:${author}:${title}:${isbn}:${publisher}:${year}:${edition}:${source}:${price}:${branch}:${status}" >> "$REQ_FILE"

                echo
                echo "Requisition added successfully!"
                echo -n "Press Enter to continue..."
                read
                ;;
            [Qq])
                return
                ;;
            *)
                echo "Invalid input! Please enter 'y' to add or 'q' to quit."
                echo -n "Press Enter to continue..."
                read
                ;;
        esac
    done
}

# ============================================
# TASK 3: Search Book Requisition by ID
# ============================================
search_requisition() {
    while true; do
        clear
        echo "Search Book Requisition by Requisition ID"
        echo -n "Enter Requisition ID: "
        read search_id

        req_line=$(grep -i "^${search_id}:" "$REQ_FILE" 2>/dev/null)

        if [ -z "$req_line" ]; then
            echo
            echo "Requisition ID not found!"
        else
            # Parse using awk to handle URL colons
            {
                read req_id
                read req_date
                read author
                read title
                read isbn
                read publisher
                read year
                read edition
                read source
                read price
                read branch
                read status
            } < <(parse_req_line "$req_line")

            staff_line=$(grep "^${req_id}:" "$STAFF_FILE" 2>/dev/null)
            IFS=':' read -r s_req_id staff_id applicant_name faculty contact email <<< "$staff_line"

            echo
            echo "Applicant Details:"
            echo "================"
            echo "Staff ID: $staff_id"
            echo "Applicant Name: $applicant_name"
            echo "Faculty/Center (FAFB/FOCS/FOAS/FOET/FSSH/CPUS): $faculty"
            echo "Contact Number: $contact"
            echo "Email: $email"
            echo
            echo "Book Requisition Details:"
            echo "======================"
            echo "Author: $author"
            echo "Title: $title"
            echo "ISBN: $isbn"
            echo "Publisher: $publisher"
            echo "Year: $year"
            echo "Edition: $edition"
            echo "Source: $source"
            echo "Price (RM): $price"
            echo "Branch/Campus (KL/PP/PH/SB/JH/PK): $branch"
            echo "Status (Approved/Pending/Disapproved): $status"
        fi

        echo
        while true; do
            echo "Press (q) to return to Book Requisition Management System Menu."
            echo -n "Search another Requisition? (y)es or (q)uit : "
            read choice

            case "$choice" in
                [Qq])
                    return
                    ;;
                [Yy])
                    break
                    ;;
                *)
                    echo "Invalid input! Please enter 'y' to search again or 'q' to quit."
                    ;;
            esac
        done
    done
}

# ============================================
# TASK 4: Update Book Requisition Details
# ============================================
update_requisition() {
    while true; do
        clear
        echo "Update Book Requisition Details"
        echo
        echo -n "Enter Requisition ID: "
        read search_id

        req_line=$(grep -i "^${search_id}:" "$REQ_FILE" 2>/dev/null)

        if [ -z "$req_line" ]; then
            echo
            echo "Requisition ID not found!"
            while true; do
                echo -n "Try another ID? (y)es or (q)uit : "
                read choice
                case "$choice" in
                    [Yy]) break ;;
                    [Qq]) return ;;
                    *) echo "Invalid input! Please enter 'y' or 'q'." ;;
                esac
            done
            continue
        fi

        # Parse using awk
        {
            read req_id
            read req_date
            read author
            read title
            read isbn
            read publisher
            read year
            read edition
            read source
            read price
            read branch
            read status
        } < <(parse_req_line "$req_line")

        echo
        echo "Author: $author"
        echo "Title: $title"
        echo "ISBN: $isbn"
        echo "Publisher: $publisher"
        echo "Year: $year"
        echo "Edition: $edition"
        echo
        echo "Enter new values (press Enter to keep current value):"

        # Source - must be URL format
        while true; do
            echo -n "Source [$source]: "
            read new_source
            if [ -z "$new_source" ]; then
                break
            elif [[ "$new_source" =~ ^https?://.+ ]]; then
                source="$new_source"
                break
            else
                echo "Invalid input! Must be URL format (e.g. https://example.com)!"
            fi
        done

        # Price - positive number, cannot start with decimal point
        while true; do
            echo -n "Price (RM) [$price]: "
            read new_price
            if [ -z "$new_price" ]; then
                break
            elif [[ "$new_price" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [[ ! "$new_price" =~ ^\. ]]; then
                price="$new_price"
                break
            else
                echo "Invalid input! Price must be a positive number (e.g. 99.90)!"
            fi
        done

        # Branch/Campus - only specific options
        while true; do
            echo -n "Branch/Campus (KL/PP/PH/SB/JH/PK) [$branch]: "
            read new_branch
            if [ -z "$new_branch" ]; then
                break
            else
                branch_upper=$(echo "$new_branch" | tr '[:lower:]' '[:upper:]')
                if [[ "$branch_upper" =~ ^(KL|PP|PH|SB|JH|PK)$ ]]; then
                    branch="$branch_upper"
                    break
                else
                    echo "Invalid input! Choose within the listed options!"
                fi
            fi
        done

        # Status - only specific options
        while true; do
            echo -n "Status (Approved/Pending/Disapproved) [$status]: "
            read new_status
            if [ -z "$new_status" ]; then
                break
            else
                status_lower=$(echo "$new_status" | tr '[:upper:]' '[:lower:]')
                case "$status_lower" in
                    approved)
                        status="Approved"
                        break
                        ;;
                    pending)
                        status="Pending"
                        break
                        ;;
                    disapproved)
                        status="Disapproved"
                        break
                        ;;
                    *)
                        echo "Invalid input! Choose within the listed options!"
                        ;;
                esac
            fi
        done

        echo
        echo "Source: $source"
        echo "Price (RM): $price"
        echo "Branch/Campus (KL/PP/PH/SB/JH/PK): $branch"
        echo "Status (Approved/Pending/Disapproved): $status"
        echo

        while true; do
            echo "Press (q) to return to Book Requisition Management System Menu."
            echo -n "Are you sure you want to UPDATE the above Requisition Details? (y)es or (q)uit: "
            read confirm

            case "$confirm" in
                [Yy])
                    new_line="${req_id}:${req_date}:${author}:${title}:${isbn}:${publisher}:${year}:${edition}:${source}:${price}:${branch}:${status}"
                    sed -i "s|^${req_id}:.*|$new_line|" "$REQ_FILE"
                    echo
                    echo "Requisition updated successfully!"
                    break
                    ;;
                [Qq])
                    return
                    ;;
                *)
                    echo "Invalid input! Please enter 'y' to update or 'q' to quit."
                    ;;
            esac
        done

        echo
        while true; do
            echo "Press (q) to return to Book Requisition Management System Menu."
            echo -n "Update another Requisition? (y)es or (q)uit : "
            read choice

            case "$choice" in
                [Qq])
                    return
                    ;;
                [Yy])
                    break
                    ;;
                *)
                    echo "Invalid input! Please enter 'y' or 'q'."
                    ;;
            esac
        done
    done
}

# ============================================
# TASK 5: Delete Book Requisition Details
# ============================================
delete_requisition() {
    while true; do
        clear
        echo "Delete Book Requisition Details"
        echo -n "Enter Requisition ID: "
        read search_id

        req_line=$(grep -i "^${search_id}:" "$REQ_FILE" 2>/dev/null)

        if [ -z "$req_line" ]; then
            echo
            echo "Requisition ID not found!"
            while true; do
                echo -n "Try another ID? (y)es or (q)uit : "
                read choice
                case "$choice" in
                    [Yy]) break ;;
                    [Qq]) return ;;
                    *) echo "Invalid input! Please enter 'y' or 'q'." ;;
                esac
            done
            continue
        fi

        # Parse using awk
        {
            read req_id
            read req_date
            read author
            read title
            read isbn
            read publisher
            read year
            read edition
            read source
            read price
            read branch
            read status
        } < <(parse_req_line "$req_line")

        echo
        echo "Author: $author"
        echo "Title: $title"
        echo "ISBN: $isbn"
        echo "Publisher: $publisher"
        echo "Year: $year"
        echo "Edition: $edition"
        echo "Source: $source"
        echo "Price (RM): $price"
        echo "Branch/Campus (KL/PP/PH/SB/JH/PK): $branch"
        echo "Status (Approved/Pending/Disapproved): $status"

        while true; do
            echo
            echo "Press (q) to return to Book Requisition Management System Menu."
            echo -n "Are you sure you want to DELETE the above Requisition Details? (y)es or (q)uit: "
            read confirm

            case "$confirm" in
                [Yy])
                    sed -i "/^${req_id}:/d" "$REQ_FILE"
                    sed -i "/^${req_id}:/d" "$STAFF_FILE"
                    echo
                    echo "Requisition deleted successfully!"
                    break
                    ;;
                [Qq])
                    return
                    ;;
                *)
                    echo "Invalid input! Please enter 'y' to delete or 'q' to quit."
                    ;;
            esac
        done

        while true; do
            echo "Press (q) to return to Book Requisition Management System Menu."
            echo -n "Delete another Requisition? (y)es or (q)uit : "
            read choice

            case "$choice" in
                [Qq])
                    return
                    ;;
                [Yy])
                    break
                    ;;
                *)
                    echo "Invalid input! Please enter 'y' or 'q'."
                    ;;
            esac
        done
    done
}

# ============================================
# TASK 6: Sort Book Requisitions Menu
# ============================================
sort_requisitions() {
   while true; do
       clear
       echo "Sort Book Requisitions"
       echo
       echo "1- Sort by Faculty (FAFB/FOCS/FOAS/FOET/FSSH/CPUS)"
       echo "2- Sort by Status (Approved/Pending/Disapproved)"
       echo "3- Sort by Requisition Date (Newest to Oldest)"
       echo
       echo "Press (q) to return to Book and Materials Requisition Management System Menu."
       echo -n "Please select a choice: "
       read choice

       case "$choice" in
           1) sort_by_faculty ;;
           2) sort_by_status ;;
           3) sort_by_date ;;
           [Qq]) return ;;
           *)
               echo "Invalid choice!"
               while true; do
                   echo -n "Try again (y)es or return to previous menu (q)uit : "
                   read retry_choice
                   case "$retry_choice" in
                       [Yy]) break ;;
                       [Qq]) return ;;
                       *) echo "Invalid input! Please enter 'y' or 'q'." ;;
                   esac
               done
               ;;
       esac
   done
}

# ============================================
# TASK 7(i): Sort by Faculty
# ============================================
sort_by_faculty() {
   clear
   echo "Requisition Details Sorted by Faculty"
   echo

   # Validate Faculty input
   while true; do
       echo -n "Enter Faculty (FAFB/FOCS/FOAS/FOET/FSSH/CPUS): "
       read faculty_input
       faculty_upper=$(echo "$faculty_input" | tr '[:lower:]' '[:upper:]')
       if [[ "$faculty_upper" =~ ^(FAFB|FOCS|FOAS|FOET|FSSH|CPUS)$ ]]; then
           break
       else
           echo "Invalid Faculty! Please choose from: FAFB, FOCS, FOAS, FOET, FSSH, CPUS"
           while true; do
               echo -n "Try again (y)es or return to previous menu (q)uit: "
               read retry_choice
               case "$retry_choice" in
                   [Yy]) break ;;
                   [Qq]) return ;;
                   *) echo "Invalid input! Please enter 'y' or 'q'." ;;
               esac
           done
       fi
   done

   # Validate Campus input
   while true; do
       echo -n "Enter Campus (KL/PP/PH/SB/JH/PK): "
       read campus_input
       campus_upper=$(echo "$campus_input" | tr '[:lower:]' '[:upper:]')
       if [[ "$campus_upper" =~ ^(KL|PP|PH|SB|JH|PK)$ ]]; then
           break
       else
           echo "Invalid Campus! Please choose from: KL, PP, PH, SB, JH, PK"
           while true; do
               echo -n "Try again (y)es or return to previous menu (q)uit: "
               read retry_choice
               case "$retry_choice" in
                   [Yy]) break ;;
                   [Qq]) return ;;
                   *) echo "Invalid input! Please enter 'y' or 'q'." ;;
               esac
           done
       fi
   done

   clear
   echo "Requisition Details Sorted by Faculty"
   echo "Faculty: $faculty_upper | Campus: $campus_upper"
   echo
   echo "Sorting records . . ."
   echo

   printf "%-14.14s %-24.24s %-30.30s %-30.30s %-12.12s %-16.16s\n" \
       "Req ID" "Author" "Title" "Publisher" "Status" "Requisition Date"
   printf "%-14.14s %-24.24s %-30.30s %-30.30s %-12.12s %-16.16s\n" \
       "--------------" "------------------------" "------------------------------" \
       "------------------------------" "------------" "----------------"

   > /tmp/temp_report.txt
   found=0

   while IFS= read -r line; do
       req_id=$(echo "$line" | cut -d':' -f1)
       req_date=$(echo "$line" | cut -d':' -f2)
       author=$(echo "$line" | cut -d':' -f3)
       title=$(echo "$line" | cut -d':' -f4)
       publisher=$(echo "$line" | cut -d':' -f6)
       branch=$(echo "$line" | awk -F':' '{print $(NF-1)}')
       status=$(echo "$line" | awk -F':' '{print $NF}')

       staff_line=$(grep "^${req_id}:" "$STAFF_FILE" 2>/dev/null)
       staff_faculty=$(echo "$staff_line" | cut -d':' -f4)
       staff_faculty_upper=$(echo "$staff_faculty" | tr '[:lower:]' '[:upper:]')
       branch_upper=$(echo "$branch" | tr '[:lower:]' '[:upper:]')

       if [ "$staff_faculty_upper" = "$faculty_upper" ] && [ "$branch_upper" = "$campus_upper" ]; then
           print_row_faculty "$req_id" "$author" "$title" "$publisher" "$status" "$req_date"
           echo "${req_id}:${author}:${title}:${publisher}:${status}:${req_date}" >> /tmp/temp_report.txt
           found=1
       fi
   done < "$REQ_FILE"

   printf "%-14.14s %-24.24s %-30.30s %-30.30s %-12.12s %-16.16s\n" \
       "--------------" "------------------------" "------------------------------" \
       "------------------------------" "------------" "----------------"

   if [ "$found" -eq 0 ]; then
       echo "No records found for Faculty: $faculty_upper and Campus: $campus_upper"
   fi

   echo
   while true; do
       echo "Press (q) to return to Book Requisition Management System Menu."
       echo -n "Would you like to export the report as ASCII text file? (y)es or (q)uit: "
       read export_choice
       case "$export_choice" in
           [Yy])
               report_name="Faculty_${faculty_upper}_${campus_upper}.txt"
               {
                   echo "Requisition Details Sorted by Faculty"
                   echo "Faculty: $faculty_upper | Campus: $campus_upper"
                   echo
                   printf "%-14.14s %-24.24s %-30.30s %-30.30s %-12.12s %-16.16s\n" \
                       "Req ID" "Author" "Title" "Publisher" "Status" "Requisition Date"
                   printf "%-14.14s %-24.24s %-30.30s %-30.30s %-12.12s %-16.16s\n" \
                       "--------------" "------------------------" "------------------------------" \
                       "------------------------------" "------------" "----------------"
                   while IFS=':' read -r r_id r_author r_title r_pub r_status r_date; do
                       print_row_faculty "$r_id" "$r_author" "$r_title" "$r_pub" "$r_status" "$r_date"
                   done < /tmp/temp_report.txt
                   printf "%-14.14s %-24.24s %-30.30s %-30.30s %-12.12s %-16.16s\n" \
                       "--------------" "------------------------" "------------------------------" \
                       "------------------------------" "------------" "----------------"
               } > "$report_name"
               echo "Report exported as: $report_name"
               echo -n "Press Enter to continue..."
               read; break
               ;;
           [Qq]) break ;;
           *) echo "Invalid input! Please enter 'y' or 'q'." ;;
       esac
   done

   rm -f /tmp/temp_report.txt
}

# ============================================
# TASK 7(ii): Sort by Status
# ============================================
sort_by_status() {
   clear
   echo "Sorted by Requisition Status"
   echo

   # Validate Status input
   while true; do
       echo -n "Enter Requisition Status (Approved/Pending/Disapproved): "
       read status_input
       status_lower=$(echo "$status_input" | tr '[:upper:]' '[:lower:]')
       case "$status_lower" in
           approved|pending|disapproved)
               case "$status_lower" in
                   approved)    status_input="Approved" ;;
                   pending)     status_input="Pending" ;;
                   disapproved) status_input="Disapproved" ;;
               esac
               break
               ;;
           *)
               echo "Invalid Status! Please choose from: Approved, Pending, Disapproved"
               while true; do
                   echo -n "Try again (y)es or return to previous menu (q)uit: "
                   read retry_choice
                   case "$retry_choice" in
                       [Yy]) break ;;
                       [Qq]) return ;;
                       *) echo "Invalid input! Please enter 'y' or 'q'." ;;
                   esac
               done
               ;;
       esac
   done

   clear
   echo "Sorted by Requisition Status"
   echo "Status: $status_input"
   echo

   printf "%-14.14s %-16.16s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s\n" \
       "Requisition ID" "Requisition Date" "Faculty" "Campus" "Author" "Title" "Publisher"
   printf "%-14.14s %-16.16s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s\n" \
       "--------------" "----------------" "--------" "--------" \
       "------------------------" "------------------------------" "------------------------"

   > /tmp/temp_report.txt
   found=0

   while IFS= read -r line; do
       req_id=$(echo "$line" | cut -d':' -f1)
       req_date=$(echo "$line" | cut -d':' -f2)
       author=$(echo "$line" | cut -d':' -f3)
       title=$(echo "$line" | cut -d':' -f4)
       publisher=$(echo "$line" | cut -d':' -f6)
       branch=$(echo "$line" | awk -F':' '{print $(NF-1)}')
       status=$(echo "$line" | awk -F':' '{print $NF}')
       current_status_lower=$(echo "$status" | tr '[:upper:]' '[:lower:]')

       if [ "$current_status_lower" = "$status_lower" ]; then
           staff_line=$(grep "^${req_id}:" "$STAFF_FILE" 2>/dev/null)
           faculty=$(echo "$staff_line" | cut -d':' -f4)

           print_row_status "$req_id" "$req_date" "$faculty" "$branch" "$author" "$title" "$publisher"
           echo "${req_id}:${req_date}:${faculty}:${branch}:${author}:${title}:${publisher}" >> /tmp/temp_report.txt
           found=1
       fi
   done < "$REQ_FILE"

   printf "%-14.14s %-16.16s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s\n" \
       "--------------" "----------------" "--------" "--------" \
       "------------------------" "------------------------------" "------------------------"

   if [ "$found" -eq 0 ]; then
       echo "No records found with Status: $status_input"
   fi

   echo
   while true; do
       echo "Press (q) to return to Book Requisition Management System Menu."
       echo -n "Would you like to export the report as ASCII text file? (y)es (q)uit: "
       read export_choice
       case "$export_choice" in
           [Yy])
               report_name="Status_${status_input}.txt"
               {
                   echo "Sorted by Requisition Status"
                   echo "Status: $status_input"
                   echo
                   printf "%-14.14s %-16.16s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s\n" \
                       "Requisition ID" "Requisition Date" "Faculty" "Campus" "Author" "Title" "Publisher"
                   printf "%-14.14s %-16.16s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s\n" \
                       "--------------" "----------------" "--------" "--------" \
                       "------------------------" "------------------------------" "------------------------"
                   while IFS=':' read -r r_id r_date r_fac r_campus r_author r_title r_pub; do
                       print_row_status "$r_id" "$r_date" "$r_fac" "$r_campus" "$r_author" "$r_title" "$r_pub"
                   done < /tmp/temp_report.txt
                   printf "%-14.14s %-16.16s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s\n" \
                       "--------------" "----------------" "--------" "--------" \
                       "------------------------" "------------------------------" "------------------------"
               } > "$report_name"
               echo "Report exported as: $report_name"
               echo -n "Press Enter to continue..."
               read; break
               ;;
           [Qq]) break ;;
           *) echo "Invalid input! Please enter 'y' or 'q'." ;;
       esac
   done

   rm -f /tmp/temp_report.txt
}

# ============================================
# TASK 7(iii): Sort by Requisition Date
# ============================================
sort_by_date() {
   clear
   echo "Requisition Details Sorted by Requisition Date"
   echo

   # Validate Date input
   while true; do
       echo -n "Enter Requisition Date (dd-mm-yyyy): "
       read date_input
       if [[ "$date_input" =~ ^[0-9]{2}-[0-9]{2}-[0-9]{4}$ ]]; then
           search_date="$date_input"; break
       else
           echo "Invalid date format! Please enter in dd-mm-yyyy format (e.g., 21-04-2026)"
           while true; do
               echo -n "Try again (y)es or return to previous menu (q)uit: "
               read retry_choice
               case "$retry_choice" in
                   [Yy]) break ;;
                   [Qq]) return ;;
                   *) echo "Invalid input! Please enter 'y' or 'q'." ;;
               esac
           done
       fi
   done

   clear
   echo "Requisition Details Sorted by Requisition Date"
   echo "Date: $search_date"
   echo

   printf "%-14.14s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s %-12.12s\n" \
       "Requisition ID" "Faculty" "Campus" "Author" "Title" "Publisher" "Status"
   printf "%-14.14s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s %-12.12s\n" \
       "--------------" "--------" "--------" "------------------------" \
       "------------------------------" "------------------------" "------------"

   > /tmp/temp_report.txt
   found=0

   while IFS= read -r line; do
       req_id=$(echo "$line" | cut -d':' -f1)
       req_date=$(echo "$line" | cut -d':' -f2)
       author=$(echo "$line" | cut -d':' -f3)
       title=$(echo "$line" | cut -d':' -f4)
       publisher=$(echo "$line" | cut -d':' -f6)
       branch=$(echo "$line" | awk -F':' '{print $(NF-1)}')
       status=$(echo "$line" | awk -F':' '{print $NF}')

       if [ "$req_date" = "$search_date" ]; then
           staff_line=$(grep "^${req_id}:" "$STAFF_FILE" 2>/dev/null)
           faculty=$(echo "$staff_line" | cut -d':' -f4)

           print_row_date "$req_id" "$faculty" "$branch" "$author" "$title" "$publisher" "$status"
           echo "${req_id}:${faculty}:${branch}:${author}:${title}:${publisher}:${status}" >> /tmp/temp_report.txt
           found=1
       fi
   done < "$REQ_FILE"

   printf "%-14.14s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s %-12.12s\n" \
       "--------------" "--------" "--------" "------------------------" \
       "------------------------------" "------------------------" "------------"

   if [ "$found" -eq 0 ]; then
       echo "No records found for Date: $date_input"
   fi

   echo
   while true; do
       echo "Press (q) to return to Book Requisition Management System Menu."
       echo -n "Would you like to export the report as ASCII text file? (y)es (q)uit: "
       read export_choice
       case "$export_choice" in
           [Yy])
               safe_date=$(echo "$date_input" | tr '-' '_')
               report_name="Date_${safe_date}.txt"
               {
                   echo "Requisition Details Sorted by Requisition Date"
                   echo "Date: $date_input"
                   echo
                   printf "%-14.14s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s %-12.12s\n" \
                       "Requisition ID" "Faculty" "Campus" "Author" "Title" "Publisher" "Status"
                   printf "%-14.14s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s %-12.12s\n" \
                       "--------------" "--------" "--------" "------------------------" \
                       "------------------------------" "------------------------" "------------"
                   while IFS=':' read -r r_id r_fac r_campus r_author r_title r_pub r_status; do
                       print_row_date "$r_id" "$r_fac" "$r_campus" "$r_author" "$r_title" "$r_pub" "$r_status"
                   done < /tmp/temp_report.txt
                   printf "%-14.14s %-8.8s %-8.8s %-24.24s %-30.30s %-24.24s %-12.12s\n" \
                       "--------------" "--------" "--------" "------------------------" \
                       "------------------------------" "------------------------" "------------"
               } > "$report_name"
               echo "Report exported as: $report_name"
               echo -n "Press Enter to continue..."
               read; break
               ;;
           [Qq]) break ;;
           *) echo "Invalid input! Please enter 'y' or 'q'." ;;
       esac
   done

   rm -f /tmp/temp_report.txt
}

# ============================================
# MAIN PROGRAM
# ============================================
initialize_files
main_menu

