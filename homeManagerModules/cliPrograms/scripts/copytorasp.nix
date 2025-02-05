{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "copytorasp"
      ''
        # Variables
        SOURCE_DIR="$1"          # The directory to copy (passed as an argument)
        PI_USER="pi"             # Your Raspberry Pi username
        PI_IP="$3"    # Your Raspberry Pi's IP address
        DEST_DIR="$2"            # The destination directory on the Raspberry Pi (passed as an argument)
        
        # Check if source directory exists
        if [ ! -d "$SOURCE_DIR" ]; then
            echo "Error: Source directory does not exist."
            exit 1
        fi
        
        # Check if destination directory is provided
        if [ -z "$DEST_DIR" ]; then
            echo "Error: No destination directory specified."
            exit 1
        fi
        
        # Run the SCP command to copy the directory to the Raspberry Pi
        scp -r "$SOURCE_DIR" "$PI_USER@$3:$DEST_DIR"
        
        # Check if SCP was successful
        if [ $? -eq 0 ]; then
            echo "Directory copied successfully."
        else
            echo "Error: Failed to copy directory."
        fi
      '')
  ];
}
