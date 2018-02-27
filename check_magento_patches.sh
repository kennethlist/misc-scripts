#!/bin/bash

# Config
MAGE_FILE="../Mage.php"
APPLIED_PATCHES_FILE="applied.patches.list"
MAGENTO_API_KEY="" #MAG...:...

# Get Magento Version
VERSION=$(cat $MAGE_FILE | grep -P "(major|minor|revision|patch|stability|number)'[=> ]+" | grep -oP "[0-9]" | tr '\n' '.')
VERSION=${VERSION::-1}

# Parse applied patches
APPLIED_PATCHES=$(cat $APPLIED_PATCHES_FILE | grep SUPEE | grep -oP '( PATCH_SUPEE-[_.0-9CEvsh-]+ | SUPEE-[_.0-9CEvsh-]+ | v[.0-9]+ | REVERTED)' | tr -d '\n' | sed 's/ SUPEE/\n&/g' | sed 's/ PATCH/\n&/g' | grep -oP '(SUPEE-[0-9]+| v[.0-9]+ |REVERTED)' | tr -d '\n' | sed 's/SUPEE/\n&/g' | sed 's/  / /g')

# Get available Magento patches for particular version
AVAILABLE_PATCHES=$(curl -sSk https://$MAGENTO_API_KEY@www.magentocommerce.com/products/downloads/info/filter/type/ce-patch | grep -P $VERSION | grep -oP '(PATCH_SUPEE-[0-9]+|_v[.0-9]+)' | sed 's/PATCH_//g' | sed 's/_v/ v/g' | sed 's/\.$//g' | tr -d '\n' | sed 's/SUPEE/\n&/g')

echo "Needed patches for Magento VERSION: $VERSION"

# =============================
# 1. Build list of applied patches
# =============================
applied_patches_array=()
while read line; do

    # remove patch if already exists; this is to prevent duplicates
    for (( i=0; i<${#applied_patches_array[@]}; i++ )); do
        if [[ ${applied_patches_array[i]} == ${line} ]]; then
            applied_patches_array=( "${applied_patches_array[@]:0:$i}" "${applied_patches_array[@]:$((i + 1))}" )
        fi
    done

    if [[ $line == *"REVERTED"* ]]; then
        # remove reverted patches 
        for (( i=0; i<${#applied_patches_array[@]}; i++ )); do
            if [[ ${applied_patches_array[i]} == ${line::-9} ]]; then
                applied_patches_array=( "${applied_patches_array[@]:0:$i}" "${applied_patches_array[@]:$((i + 1))}" )
            fi
        done
    else
        # adds patch; assumes success
        applied_patches_array+=("${line}")
    fi
done <<< "$APPLIED_PATCHES"


# =============================
# 2. Build array of available patches for Magento version
# =============================
available_patches_array=()
while read line; do
    if [[ $line == *"SUPEE-9652 v2"* ]]; then
        available_patches_array+=("SUPEE-9652 v1") # fix mismatch versions; there is no v1
    else
        available_patches_array+=("$line")
    fi
done <<< "$AVAILABLE_PATCHES"


# =============================
# 3. Determine which patches haven't been applied
# =============================
for i in "${available_patches_array[@]}"
do

    has_higher_version="false"
    if [[ ! " ${applied_patches_array[@]} " =~ " ${i} " ]]; then

        # check for higher version of patch (e.g. v2 or v1.1)
        stringarray=($i)
        for item in "${available_patches_array[@]}"
        do
            if printf -- '%s' "$item" | egrep -q -- "${stringarray[0]}"; then
                if [[ ${#item} == ${#i} && $item > ${i} ]]; then
                    has_higher_version="true"
                fi
                if [[ ${#item} > ${#i} ]]; then
                    has_higher_version="true"
                fi
            fi
        done

        # if not higher version
        if [[ "${has_higher_version}" == "false" ]]; then
            echo "${i}"
        fi

    fi
done
