#!/bin/bash

set -e

# Define the SQLite database file
DB_FILE="$HOME/notes.db"

# Function to initialize the database and table if it doesn't exist
initialize_db() {
    sqlite3 $DB_FILE "CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, title TEXT, content TEXT);"
}

# Function to add a new note
add_note() {
    title="$1"
    content="$2"
    sqlite3 $DB_FILE "INSERT INTO notes (title, content) VALUES ('$title', '$content');"
    echo "Note added!"
}

# Function to view note titles
view_titles() {
    echo "=============================="
    echo "        Note Titles           "
    echo "=============================="
    sqlite3 $DB_FILE "SELECT id, title FROM notes;" | awk -F'|' '{print $1 ": " $2}'
    echo "=============================="
}

# Function to view a specific note by ID
view_note_by_id() {
    note_id="$1"
    sqlite3 $DB_FILE "SELECT title, content FROM notes WHERE id=$note_id;" | while IFS='|' read -r title content; do
        echo "=============================="
        echo "Title: $title"
        echo "Content: $content"
        echo "=============================="
    done
}

# Function to update a note by ID
update_note() {
    note_id="$1"
    new_title="$2"
    new_content="$3"
    sqlite3 $DB_FILE "UPDATE notes SET title='$new_title', content='$new_content' WHERE id=$note_id;"
    echo "Note updated!"
}

# Function to delete a note by ID
delete_note() {
    note_id="$1"
    sqlite3 $DB_FILE "DELETE FROM notes WHERE id=$note_id;"
    echo "Note deleted!"
}

# Function to search notes by title
search_notes() {
    search_term="$1"
    echo "=============================="
    echo "      Search Results          "
    echo "=============================="
    sqlite3 $DB_FILE "SELECT id, title FROM notes WHERE title LIKE '%$search_term%';" | awk -F'|' '{print $1 ": " $2}'
    echo "=============================="
}

# Initialize the database if not already created
initialize_db

# Check arguments and run corresponding actions
while getopts "t:c:v:d:u:s" opt; do
    case $opt in
        t) title="$OPTARG" ;;
        c) content="$OPTARG" ;;
        v) view_note_by_id "$OPTARG" ;;
        d) delete_note "$OPTARG" ;;
        u) update_note_id="$OPTARG"; shift 2; update_title="$1"; update_content="$2" ;; # Shift to parse next two arguments
        s) search_notes "$OPTARG" ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
done

# If both title and content are provided, add a new note
if [ ! -z "$title" ] && [ ! -z "$content" ]; then
    add_note "$title" "$content"
fi

# If updating a note, ensure title and content are provided
if [ ! -z "$update_note_id" ] && [ ! -z "$update_title" ] && [ ! -z "$update_content" ]; then
    update_note "$update_note_id" "$update_title" "$update_content"
fi

# If no arguments were provided, list all titles
# '#' refers to the number of arguments passed to the script.
# '$#' is a special variable in shell scripting that holds the count of the arguments provided to the script.
if [ $# -eq 0 ]; then
    view_titles
fi

