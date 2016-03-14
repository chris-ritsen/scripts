
# host=$(hostname)

host='desktop'

target_dir="/Media/Travel/${host}/"

sudo mkdir -p "${target_dir}"

sudo rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/Media/","/home/*"} /opt/* ${target_dir}/opt/*

