#!/bin/bash

if [! -f staff.txt]
	then
	echo "Staff file does not exist.
Creating staff.txt…"
	touch staff.txt "Requisition_ID:Staff_ID:Applicant_Name:Faculty:Contact_Number:Email"
if [! -f requisition.txt]
	then
	echo "Book requistion file does not exist.
Creating requisition.txt…"
	touch requisition.txt "Requisition_ID:Requisition_Date:Author:Title:ISBN:Publisher:Year:Edition:Source:Price:Branch:Status"


menuStart = "Book Requisition Management System
A – Add New Book Requisition Details
U – Update Book Requisition Details
D – Delete Book Requisition Details
S – Search Book Requisition Details
R – Sort Book Requisitions

Q – Exit from Program

Please select a choice: "

echo -n $menuStart
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
