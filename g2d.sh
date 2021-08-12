#!/bin/bash

GITIGNORE_FILES=( $( find . -name ".gitignore" ) )
FILES=${#GITIGNORE_FILES[@]}

if [[ $FILES -eq 0 ]]; then
    echo "No gitignore files found."
    exit 0
fi

# Check for the existance of a deployignore file, if one exists, copy it to .deployignore.bak
if [[ -f .deployignore ]]; then
    mv .deployignore .deployignore.bak
fi

# Create a new .deployignore file
# Add a comment to the start of the deployignore file
#   Format: "# This file was generated automatically. Changes may be overwritten. To modify, update your gitignore files, or create a .deployignore.g2d file in the root of your project."
echo "# This file was generated automatically. Changes may be overwritten. Do not modify directly." > .deployignore
echo "# If modifications are necessary, modify your .gitignore files, or create a .deployignore.g2d file in the root of your project." >> .deployignore
echo "" >> .deployignore

# Check for a .deployignore.g2d file in the current directory, if it exists append it's contents to the deployignore file.
if [[ -f .deployignore.g2d ]]; then
    cat .deployignore.g2d >> .deployignore
fi

for IGNOREFILE in "${GITIGNORE_FILES[@]}"
do
    echo "Processing ${IGNOREFILE}..."
    # Copy the text of the .gitignore file to a temporary file
    cp $IGNOREFILE /tmp/.tempignore

    # Get the full path to the ignore file, sans the .gitignore and save it to a variable
    FULL_PATH=$( echo ${IGNOREFILE} | sed -e 's/\.gitignore//g' | sed -e 's/\.\///g' )

    # If the full path still contains text:
    if [ ! -z "${FULL_PATH}" ]; then
        SANITIZED_PATH=$(echo $FULL_PATH|tr -d '\n')
        while read line; do 
            if [[ -z $line ]]; then 
                echo "" >> /tmp/.sanitempignore
                continue; 
            fi 
            
            if [[ ${line:0:1} == "#" ]]; then 
                echo "${line}" >> /tmp/.sanitempignore
                continue
            fi

            # If the line is an ignore line, don't forget to make those work.
            if [[ ${line:0:1} == "!" ]]; then
                line=${line:1}
                SANITIZED_PATH="!${SANITIZED_PATH}"
            fi

            if [[ ${line:0:1} == "/" ]]; then 
                line=${line:1}
            fi
            
            echo "${SANITIZED_PATH}${line}" >> /tmp/.sanitempignore
        done < /tmp/.tempignore

        rm /tmp/.tempignore

        # Append a comment to the deployignore file referencing the original gitignore location
        #   Something like "# Original contents found in ./some/subdirectory/.gitignore"
        echo "# Original contents found in ${FULL_PATH}.gitignore" >> .deployignore
        echo "" >> .deployignore

        # Append the contents of the temporary file to the new deploy ignore file.
        cat /tmp/.sanitempignore >> .deployignore

        echo "" >> .deployignore
        echo "# END OF ${FULL_PATH}.gitignore" >> .deployignore
        echo "" >> .deployignore
        
        # Remove the temporary file
        rm /tmp/.sanitempignore
    fi
    echo "Finished ${IGNOREFILE}..."
done