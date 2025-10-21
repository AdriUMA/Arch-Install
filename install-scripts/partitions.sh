# this step can not be executed using preset, as it requires user interaction due risk of data loss
unset retry_step
unset proceed_partitions

echo "${MAGENTA}Partitions${RESET}"
echo "${WARNING}ATTENTION: If you don't know what you are doing, proceed with caution! Data loss may occur!${RESET}"
echo "$(colorize_prompt "$NOTE"  "cfdisk will be used" )"

ask_yes_no " Do you want to proceed?" proceed_partitions

if [ "$proceed_partitions" != "y" ] && [ "$proceed_partitions" != "Y" ]; then
    printf "\n%.0s" {1..2}
    echo "${INFO} Partitioning aborted. ${SKY_BLUE}No changes in your system.${RESET} ${YELLOW}Goodbye!${RESET}"
    printf "\n%.0s" {1..2}
    exit 1
fi

retry_step="Y"
while [[ "$retry_step" =~ ^[Yy]$ ]]; do

    echo
    lsblk
    echo

    custom_read " Please enter a device for partitioning (e.g. /dev/sda)${RESET}" partition_device
    cfdisk "$partition_device"

    # Ask if the user wants to continue installation or retry this script
    unset retry_step
    ask_yes_no " Do you want to partition another device (y/n)?${RESET}" retry_step
done

echo "${INFO} Partitions completed!${RESET}"