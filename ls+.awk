function print_multic() {
# multicolumn output computation
    bestC = 1
    pad = 2
    width = TERMW
    # Upper bound for number of columns
    Cmax = 1 + int((width - maxw) / (minw + pad))
    if (Cmax < 1) Cmax = 1
    if (Cmax > n) Cmax = n
    if (ONE_FLAG) { Cmax=1 }
    colw[1] = 0
    # Try possible column counts from Cmax down to 1
    for (C = Cmax; C >= 1; C--) {
        R = int((n + C - 1) / C)
        if (C==1) {
          bestC=1
          break
        }
        # Compute per-column width
        for (c = 1; c <= C; c++) colw[c] = 0

        for (i = 1; i <= n; i++) {
            c = int((i-1) / R) + 1
            if (vlen_a[i] > colw[c]) colw[c] = vlen_a[i]
        }

        # Compute total width = sum(col widths) + padding
        total = 0
        for (c = 1; c <= C; c++) {
            total += colw[c]
            if (c < C) total += pad
        }

        if (total <= width) {
            bestC = C
            break      # largest possible C found → optimal
        }
    }
    # If only one column → trivial print, fastest path
    if (bestC == 1) {
        for (i = 1; i <= n; i++)
            print dec_short_a[i]
        return
    }
    C = bestC

    # print rows
    for (r = 1; r <= R; r++) {
        for (c = 1; c <= C; c++) {
            i = (c-1)*R + r
            if (i > n) break
            # padding if not last column
            if (c < C) spaces = colw[c] - vlen_a[i] + pad
            else spaces = 0
            printf("%s%*s", dec_short_a[i], spaces, "")
        }
        printf("\n")
    }
    fflush()
}
function print_long() {
    if (total_line) print total_line
    total_line = ""
    for (i=1;i<=n;i++) {
        if (name_a[i] == "" || dec_long_a[i] == "") continue
        if (INUM_FLAG)
           printf("%s%*s ", colors[COL_INUM], max_inums, inums_a[i])
        printf("%s%-*s %s%-*s %-*s",
            colors[cols_a[i]], 11, perms_a[i], colors[COL_USER], max_owner, owner_a[i], max_group, group_a[i])
        if (CONT_FLAG)
            printf(" %s%*s", colors[COL_CONTEXT], max_context,context_a[i])
        printf(" %s%*s %s %s\n", colors[COL_SIZE], max_size, size_a[i], colors[COL_DATE] date_a[i], dec_long_a[i])
    }
}
function fgcol(num) {
    return ESC num "m"
}
function fglcol(num) {
    return ESC num+60 "m"
}
function print_ls() {
    if (LONG_FLAG) print_long()
    else print_multic()
    n=0; max_links=0; max_owner=0; max_group=0; max_size=0; max_inums=0; maxw=0;
}
BEGIN {
    while ((getline < iconfile) > 0)
        for(i=2;i<=NF;i++) EXT_ICON[$i]=$1
    close(iconfile)
    while ((getline < colorfile) > 0)
        for(i=2;i<=NF;i++) EXT_COLOR[$i]=$1
    close(colorfile)
    ESC="\033["
    split("black,red,green,yellow,blue,magenta,cyan,white", colors, ",")
    for(i=1;i<=8;i++) {
        colors[colors[i]] = fgcol(i+29)
        colors["l"colors[i]] = fglcol(i+29)
    }
    RESET=ESC "0m"
    ICON_FOLDER=EXT_ICON["folder"]
    ICON_FILE=EXT_ICON["file"]
    ICON_EXEC=EXT_ICON["exec"]
    ICON_SYMLINK=EXT_ICON["symlink"]

    COL_DIR=EXT_COLOR["folder"]
    COL_EXE=EXT_COLOR["exec"]
    COL_LINK=EXT_COLOR["symlink"]
    COL_IMAGE=EXT_COLOR["image"]
    COL_DATE=EXT_COLOR["date"]
    COL_USER=EXT_COLOR["user"]
    COL_SIZE=EXT_COLOR["size"]
    COL_CONTEXT=EXT_COLOR["context"]
    COL_INUM=EXT_COLOR["inum"]
    COL_DEFAULT=EXT_COLOR["default"]
    
    FS="\t"
    prevempty=0
    nr=1
}
# handle ls error messages
/^(ls|gls):/ { print_ls();print colors["lred"] $0 RESET >"/dev/stderr"; nr=1; next }
# gnu ls bug directory title line with not escaped spaces / best effort
nr==1 && /:$/ && !/\\ / && !/^[dlsbpc-]([r-][w-][xSsTt-]){3} +[0-9]+ / { gsub(/\\/,""); nr=0; print $0; next }
prevempty && /:$/ { gsub(/\\/,""); prevempty=0; print $0; next }
{ prevempty=0; nr=0 }
$0=="" { prevempty=1; print_ls(); print ""; next }
/^total / { total_line = $0; next }
{ # preprocess line to have tab field separator
    sub(/^ */, "")        # remove leading spaces
    gsub(/\\ /, "\\x20")  # protect escaped spaces (\ )
    gsub(/ +/, "\t")      # replace remaining (unescaped) spaces with tabs
    gsub(/\\x20/, " ")    # restore escaped spaces
    gsub(/\\\\/,"\\")     # restore backslashes
}
{
    c = 1
    if (INUM_FLAG) inum=$(c++)
    perms = $(c++); links = $(c++); owner = $(c++); group = $(c++);
    if (CONT_FLAG) context=$(c++) 
    # special handling for /dev with xx, yy instead of size
    if (perms ~ /^c/ || perms ~ /^b/) size = $(c++)$(c++)
    else size = $(c++)
    date = $(c++) " " $(c++); fname=$(c++); target=$(c+1)
    is_dir = (substr(perms,1,1) == "d")
    is_link = (substr(perms,1,1) == "l")
    is_exe = (index(perms, "x") > 0)
    ext = ""
    if (match(fname, /\.([^.]+)$/, ex)) ext = tolower(ex[1])

    icon = ICON_FILE; col = COL_DEFAULT
    if (is_link) { icon = ICON_SYMLINK; col = COL_LINK }
    else if (is_dir) { icon = ICON_FOLDER; col = COL_DIR }
    else if (is_exe) { icon = ICON_EXEC; col = COL_EXE }
    else if (ext in EXT_COLOR) col = EXT_COLOR[ext]
    if (ext in EXT_ICON && ! is_link) icon = EXT_ICON[ext]

    vlen = length(fname) + 2
    if (vlen > maxw) maxw = vlen
    if (n==1 || vlen < minw) minw = vlen
    display_name = fname
    if (is_link && target != "") display_name = display_name " -> " target
    dec_long = colors[col] icon " " display_name RESET
    dec_short = colors[col] icon " " fname RESET

    ++n
    if (length(inum) > max_inums) max_inums = length(inum)
    if (length(links) > max_links) max_links = length(links)
    if (length(owner) > max_owner) max_owner = length(owner)
    if (length(group) > max_group) max_group = length(group)
    if (length(size) > max_size) max_size = length(size)
    if (length(context) > max_context) max_context = length(context)
    inums_a[n]=inum; perms_a[n]=perms; links_a[n]=links; owner_a[n]=owner; group_a[n]=group; size_a[n]=size;
    date_a[n]=date; name_a[n]=fname; dec_short_a[n]=dec_short; dec_long_a[n]=dec_long; vlen_a[n]=vlen
    context_a[n]=context
    cols_a[n]=col
}

END {
    if (LONG_FLAG) print_long()
    else print_multic()
}
