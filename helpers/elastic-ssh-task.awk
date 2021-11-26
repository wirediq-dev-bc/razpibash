#!/usr/bin/awk -f 

# Modify ~/.ssh/config values. Defaults to dry-run mode.
# To commit changes the '-i inplace' flag must be present on command line.

BEGIN {
    # Default 'Host ec2', '-v host=<name>' to changes other Hostnames in ~/.ssh/config.
    # Only include 'Host >shortname<' when setting variable on CLI.
    ssh_host = "# ssh ec2";
    if ( host ) {
        ssh_host = "# ssh "host""; 
    }
    # Host <host>.record defaults to 'Hostname'
    mod_record = "Hostname";
    if ( record ) { 
        mod_record = record;
    }
    # Update is required parameter.
    if ( ! updates ) { 
        printf("error: cli-flag: --updates= unset\n") > "/dev/stderr";
        exit 1;
    }
    existing = "";
}
{ 
    # Scan '~/.ssh/config.readline' for 'Host <host>' match.
    if ( $0 !~ ssh_host ) {
        printf("%s\n", $0);
    } else {
        # Found Host <host>; then `while getline` until finding 'mod_record'.
        while ($1 !~ mod_record) {
            printf("%s\n", $0); 
            if (getline <= 0) {
                print("raised: getlineError: %s\n", ERRNO) > "/dev/stderr";
                exit 1;
            }
        }
        # Pattern swap.
        FS = " ";
        existing = $2;
        gsub(existing, updates, $0);
        printf("%s\n", $0); 
    }
}
END {
    if ( updates && ! quiet ) {
        stat_results = "\nawk:updates:: %s: %s: %s\ngsubs(%s, %s)\n\n";
        printf(stat_results, \
               FILENAME, \
               ssh_host, \
               mod_record, \
               existing, \
               updates) > "/dev/stderr";
    }
}

