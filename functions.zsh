# Custom command to print all files and their contents
print_files_contents() {
  local dir="."
  local recursive=false
  local ignore_dotfiles=false

  # Function to print file contents
  print_file_contents() {
    local file="$1"
    echo "---------------------------------------------------"
    echo "File: $file"
    echo "---------------------------------------------------"
    cat "$file"
    echo ""
  }

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -R|--recursive)
        recursive=true
        ;;
      --ignore-dotfiles)
        ignore_dotfiles=true
        ;;
      -*)
        echo "Error: Invalid option $1"
        return 1
        ;;
      *)
        if [[ -n "$dir" ]]; then
          dir="$1"
        fi
        ;;
    esac
    shift
  done

  # Check if directory exists
  if [[ ! -d "$dir" ]]; then
    echo "Error: Directory $dir does not exist."
    return 1
  fi

  # Print header message
  echo "==================================================="
  echo "Printing files in: $dir"
  echo "==================================================="

  # Find and print files
  if [[ $recursive == true ]]; then
    # Recursive find
    if [[ $ignore_dotfiles == true ]]; then
      find "$dir" -type f -not -path "*/.*" -print | while read file; do
        print_file_contents "$file"
      done
    else
      find "$dir" -type f -print | while read file; do
        print_file_contents "$file"
      done
    fi
  else
    # Non-recursive find
    if [[ $ignore_dotfiles == true ]]; then
      find "$dir" -maxdepth 1 -type f -not -path "*/.*" -print | while read file; do
        print_file_contents "$file"
      done
    else
      find "$dir" -maxdepth 1 -type f -print | while read file; do
        print_file_contents "$file"
      done
    fi
  fi

  # Print message for subdirectories if not printed
  if [[ $recursive == false ]]; then
    if [[ $ignore_dotfiles == true ]]; then
      find "$dir" -mindepth 1 -maxdepth 1 -type d -not -path "*/.*" -print | while read subdir; do
        echo "Subdirectory: $subdir (skipping files inside)"
      done
    else
      find "$dir" -mindepth 1 -maxdepth 1 -type d -print | while read subdir; do
        echo "Subdirectory: $subdir (skipping files inside)"
      done
    fi
  fi
}

