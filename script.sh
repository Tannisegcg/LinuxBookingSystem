#!/bin/bash

if [ ! -f staff.txt ]
	then
	echo "Staff file does not exist.
Creating staff.txt…"
	echo "Requisition_ID:Staff_ID:Applicant_Name:Faculty:Contact_Number:Email" >> staff.txt
fi

if [ ! -f requisition.tx t]
	then
	echo "Book requistion file does not exist.
Creating requisition.txt…"
	echo "Requisition_ID:Requisition_Date:Author:Title:ISBN:Publisher:Year:Edition:Source:Price:Branch:Status" >> requisition.txt
fi

menuStart="Book Requisition Management System
\nA – Add New Book Requisition Details
\nU – Update Book Requisition Details
\nD – Delete Book Requisition Details
\nS – Search Book Requisition Details
\nR – Sort Book Requisitions
\n
\nQ – Exit from Program
\n
\nPlease select a choice: "

printf "%s" "$menuStart"
read choiceStart
case "$choiceStart" in
a|A)
	echo -n "Add New Book Requisition Details Form
========================
Requisition ID (auto-generate): "
	read inputReqID
	echo -n "Requisition date: "
	read inputReqDate
	echo -n "
Applicant Details:
Staff ID: "
	read inputStaffID
	echo -n "Applicant name: "
	read inputAppliName
	echo -n "Faculty/Center (FAFB/FOCS/FOAS/FOET/FSSH/CPUS): "
	read inputFacCentr
	echo -n "Contact number: "
	read inputContactNum
	echo -n "Email: "
	read inputEmail
	echo -n "
Book Requisition Details:
Author: "
	read inputBookAuthor

	echo -n "Title: "
	read inputBookTitle
	echo -n "ISBN: "
	read inputBookISBN
	echo -n "Publisher: "
	read inputBookPub
	echo -n "Year: "
	read inputBookYear
	echo -n "Edition: "
	read inputBookEdition
	echo -n "Source: "
	read inputBookSource
	echo -n "Price (RM): "
	read inputBookPrice
	echo -n "Branch/Campus (KL/PP/PH/SB/JH/PK): "
	read inputBookLocation
	echo -n "Status (Approved/Pending/Disapproved): "
	read inputBookStatus

esac