import curses
import sys

# Global variables for search results, copied text, undo history, and search highlight
search_keyword = ''
clipboard = ''
undo_stack = []
search_index = -1  # Track the position of the current search result

def init_colors():
    """Initialize color pairs for highlighting."""
    curses.start_color()
    curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_YELLOW)  # Highlight with yellow background

def draw_help_bar(stdscr):
    """Draw the help bar at the bottom of the screen with keybindings."""
    help_text = "^S Save  ^X Exit  ^H Help  ^F Search  ^K Copy  ^Z Undo"
    stdscr.addstr(curses.LINES - 1, 0, help_text[:curses.COLS - 1])  # Draw help bar at the bottom

def draw_title_bar(stdscr, filename):
    """Draw the title bar at the top of the screen with the filename."""
    title = f"edi GUI beta - {filename}"
    stdscr.addstr(0, 0, title[:curses.COLS - 1])  # Draw title at the top with filename

def display_help(stdscr):
    """Display help message."""
    help_message = """
    edi GUI beta (Version: Kuro)

    ^S  Save
    ^X  Exit
    ^H  Help
    ^F  Search (Find)
    ^K  Copy Line
    ^Z  Undo
    Press any key to return...
    """
    stdscr.clear()
    stdscr.addstr(0, 0, help_message)
    stdscr.refresh()
    stdscr.getch()  # Wait for a key press to return to the editor

def search_word(stdscr, lines, current_line, current_col):
    """Prompt for a search term and highlight it."""
    global search_keyword, search_index

    stdscr.clear()
    stdscr.addstr(0, 0, "Enter search term: ")
    stdscr.refresh()

    curses.echo()
    search_keyword = stdscr.getstr(1, 0).decode('utf-8')  # Capture user input
    curses.noecho()

    # Search for the term in the lines
    search_index = -1  # Reset search index
    for idx, line in enumerate(lines):
        if search_keyword in line:
            search_index = idx
            break

    if search_index >= 0:
        current_line = search_index + 1  # Move to the line with the match
        current_col = lines[search_index].index(search_keyword)
    else:
        stdscr.addstr(3, 0, "No matches found!")
        stdscr.refresh()
        stdscr.getch()

    return current_line, current_col

def copy_line(current_line, lines):
    """Copy the current line to the clipboard."""
    global clipboard
    clipboard = lines[current_line - 1]
    return clipboard

def save_state_for_undo(lines):
    """Save a snapshot of the current state for undo purposes."""
    undo_stack.append(lines[:])  # Save a copy of the current lines

def undo_last_change(lines):
    """Undo the last change."""
    if undo_stack:
        return undo_stack.pop()  # Restore the last saved state
    return lines  # If nothing to undo, return the current state

def handle_delete_key(current_line, current_col, lines):
    """Handle the Delete key, which removes the character after the cursor."""
    if current_col < len(lines[current_line - 1]):
        # Remove character at the current cursor position
        lines[current_line - 1] = lines[current_line - 1][:current_col] + lines[current_line - 1][current_col + 1:]
    elif current_line < len(lines):
        # If the cursor is at the end of the line, join with the next line
        lines[current_line - 1] += lines.pop(current_line)

def prompt_save_before_exit(stdscr, filename, lines):
    """Prompt the user to save before exiting."""
    stdscr.clear()
    stdscr.addstr(0, 0, "Save changes before exiting? (y/n)")
    stdscr.refresh()
    key = stdscr.getch()
    if key == ord('y') or key == ord('Y'):
        # Save the file
        with open(filename, 'w') as file:
            file.write("".join(lines) + "\n")  # Ensure new lines are saved
        stdscr.addstr(1, 0, "File saved!")
        stdscr.refresh()
        stdscr.getch()  # Wait for keypress to acknowledge
        return True  # Exit after saving
    elif key == ord('n') or key == ord('N'):
        return True  # Exit without saving
    else:
        return False  # Cancel exit

def handle_new_line(current_line, current_col, lines):
    """Insert a new line at the current cursor position."""
    save_state_for_undo(lines)  # Save the current state for undo

    # Split the current line into two at the cursor position
    if current_col < len(lines[current_line - 1]):
        new_line = lines[current_line - 1][current_col:]  # Get content after the cursor
        lines[current_line - 1] = lines[current_line - 1][:current_col]  # Keep content before cursor
        lines.insert(current_line, new_line)  # Insert new line with remaining content
    else:
        # If cursor is at the end of the line, simply insert a new blank line
        lines.insert(current_line, "")
    
    # Move cursor to the start of the new line
    return current_line + 1, 0  # New line, and cursor at the beginning of that line

def main(stdscr, filename=None):
    global undo_stack, search_index, search_keyword
    curses.curs_set(1)  # Show the cursor
    init_colors()  # Initialize colors for highlighting
    stdscr.clear()
    stdscr.refresh()

    # Buffer to hold file contents
    lines = []
    current_line = 1
    current_col = 0
    max_y, max_x = stdscr.getmaxyx()  # Get terminal size
    scroll_offset = 0  # Track where the view starts

    # Load file if provided
    if filename:
        try:
            with open(filename, 'r') as file:
                lines = file.readlines()
        except FileNotFoundError:
            lines = [""]  # Create a new file buffer if not found
    else:
        lines = [""]

    # Main editor loop
    while True:
        stdscr.clear()

        # Draw title and help bar with filename
        draw_title_bar(stdscr, filename)
        draw_help_bar(stdscr)

        # Only display visible part of the file
        for i, line in enumerate(lines[scroll_offset:scroll_offset + max_y - 3]):  # Leave room for the title and help bar
            try:
                # Display line numbers before the content
                line_number = scroll_offset + i + 1  # Calculate line number
                stdscr.addstr(i + 1, 0, f"{line_number:3} | ")  # Show line number with padding

                # Highlight search keyword in the line
                if search_keyword and search_keyword in line:
                    start_idx = line.index(search_keyword)
                    end_idx = start_idx + len(search_keyword)
                    stdscr.addstr(i + 1, 6, line[:start_idx])  # Text before match
                    stdscr.addstr(i + 1, 6 + start_idx, line[start_idx:end_idx], curses.color_pair(1))  # Highlighted match
                    stdscr.addstr(i + 1, 6 + end_idx, line[end_idx:max_x - 6])  # Text after match
                else:
                    stdscr.addstr(i + 1, 6, line[:max_x - 6])  # Normal line
            except curses.error:
                pass  # Ignore drawing errors when lines exceed terminal bounds

        stdscr.move(current_line - scroll_offset, current_col + 6)  # Move cursor (with 6-character offset for line numbers)
        stdscr.refresh()

        key = stdscr.getch()  # Get user input

        # Handle key presses
        if key == curses.KEY_UP:
            if current_line > 1:
                current_line -= 1
                if current_line < scroll_offset:
                    scroll_offset -= 1
            current_col = min(current_col, len(lines[current_line - 1]))
        elif key == curses.KEY_DOWN:
            if current_line < len(lines):
                current_line += 1
                if current_line >= scroll_offset + max_y - 3:
                    scroll_offset += 1
            current_col = min(current_col, len(lines[current_line - 1]))
        elif key == curses.KEY_LEFT:
            if current_col > 0:
                current_col -= 1
        elif key == curses.KEY_RIGHT:
            if current_col < len(lines[current_line - 1]):
                current_col += 1
        elif key == 127 or key == 8:  # Backspace
            save_state_for_undo(lines)  # Save state before modifying
            if current_col > 0:
                lines[current_line - 1] = lines[current_line - 1][:current_col - 1] + lines[current_line - 1][current_col:]
                current_col -= 1
            elif current_line > 1:
                current_col = len(lines[current_line - 2])
                lines[current_line - 2] += lines[current_line - 1]
                lines.pop(current_line - 1)
                current_line -= 1
        elif key == curses.KEY_DC:  # Delete key
            save_state_for_undo(lines)
            handle_delete_key(current_line, current_col, lines)
        elif key == ord('\n') or key == curses.KEY_ENTER or key == 10 or key == 13:  # Handle Enter key
            current_line, current_col = handle_new_line(current_line, current_col, lines)
        elif key == 32:  # Spacebar
            save_state_for_undo(lines)  # Save state before modifying
            lines[current_line - 1] = lines[current_line - 1][:current_col] + " " + lines[current_line - 1][current_col:]
            current_col += 1
        elif key == 19:  # Ctrl+S to save
            with open(filename, 'w') as file:
                file.write("".join(lines) + "\n")  # Ensure new lines are saved
        elif key == 24:  # Ctrl+X to exit
            if prompt_save_before_exit(stdscr, filename, lines):
                break  # Exit after handling the save prompt
        elif key == 8:  # Ctrl+H for help
            display_help(stdscr)
        elif key == 6:  # Ctrl+F to search (Find)
            current_line, current_col = search_word(stdscr, lines, current_line, current_col)
        elif key == 11:  # Ctrl+K to copy the current line
            copy_line(current_line, lines)
        elif key == 26:  # Ctrl+Z to undo
            lines = undo_last_change(lines)
        else:
            if key != -1 and key < 256:  # Only handle valid character keys
                save_state_for_undo(lines)  # Save state before modifying
                lines[current_line - 1] = lines[current_line - 1][:current_col] + chr(key) + lines[current_line - 1][current_col:]
                current_col += 1
                if current_col >= max_x - 6:
                    current_col = max_x - 7

    # Restore the terminal when exiting
    curses.endwin()

if __name__ == "__main__":
    # Use sys.argv to get the filename from command line argument
    if len(sys.argv) < 2:
        print("Usage: python edi.py <filename>")
        sys.exit(1)
    
    filename = sys.argv[1]  # Get the filename from the argument
    curses.wrapper(main, filename)
