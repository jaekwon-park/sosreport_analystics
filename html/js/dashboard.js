function generate_os_data(url, element) {
    $.get(url, function(data) {
        $(element).text(data);
    },"json");
}

// If dataTable with provided ID exists, destroy it.
function destroy_dataTable(table_id) {
    var table = $("#" + table_id);
    var ex = document.getElementById(table_id);
    if ($.fn.DataTable.fnIsDataTable(ex)) {
        table.hide().dataTable().fnClearTable();
        table.dataTable().fnDestroy();
    }
}

//DataTables
//Sort file size data.
jQuery.extend(jQuery.fn.dataTableExt.oSort, {
    "file-size-pre": function(a) {
        var x = a.substring(0, a.length - 1);
        var x_unit = (a.substring(a.length - 1, a.length) === "M" ?
                      1000 : (a.substring(a.length - 1, a.length) === "G" ?
                              1000000 : 1));

        return parseInt(x * x_unit, 10);
    },

    "file-size-asc": function(a, b) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "file-size-desc": function(a, b) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
});

//DataTables
//Sort numeric data which has a percent sign with it.
jQuery.extend(jQuery.fn.dataTableExt.oSort, {
    "percent-pre": function(a) {
        var x = (a === "-") ? 0 : a.replace(/%/, "");
        return parseFloat(x);
    },

    "percent-asc": function(a, b) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "percent-desc": function(a, b) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
});

/*******************************
  Data Call Functions
 *******************************/

var dashboard = {};

dashboard.getPs = function() {
    $.get("sh/ps.php", function(data) {
        destroy_dataTable("ps_dashboard");
        $("#filter-ps").val("").off("keyup");

        var psTable = $("#ps_dashboard").dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "USER" },
                { sTitle: "PID" },
                { sTitle: "%CPU" },
                { sTitle: "%MEM" },
                { sTitle: "VSZ" },
                { sTitle: "RSS" },
                { sTitle: "TTY" },
                { sTitle: "STAT" },
                { sTitle: "START" },
                { sTitle: "TIME" },
                { sTitle: "COMMAND" }
            ],
            bPaginate: false,
            sPaginationType: "full_numbers",
            bFilter: true,
            aaSorting: [[4, "desc"]],
            sDom: "lrtip",
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();

//        $("#filter-ps").on("keyup", function() {
//            psTable.fnFilter(this.value);
//        });
    }, "json");
}

dashboard.getNetstat = function() {
    $.get("sh/netstat.php", function(data) {
        var table = $("#netstat_dashboard");
        var ex = document.getElementById("netstat_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }
        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "Protocol" },
                { sTitle: "Recv-Q" },
                { sTitle: "Send-Q" },
                { sTitle: "local adress" },
                { sTitle: "remote adress" },
                { sTitle: "State" },
                { sTitle: "PID" }
            ],
            bPaginate: false,
            bFilter: false,
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}
dashboard.getKdump= function() {
    $.get("sh/kdump.php", function(data) {
        var table = $("#kdump_dashboard");
        var ex = document.getElementById("kdump_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }
        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "kdump.conf 파일 내용 "}
            ],
            bPaginate: false,
            bFilter: false,
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}


dashboard.getError = function() {
    $.get("sh/error.php", function(data) {
        var table = $("#error_dashboard");
        var ex = document.getElementById("error_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }
        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "message" }
            ],
            bPaginate: false,
            bFilter: false,
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}

dashboard.getFail = function() {
    $.get("sh/fail.php", function(data) {
        var table = $("#fail_dashboard");
        var ex = document.getElementById("fail_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }
        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "message" }
            ],
            bPaginate: false,
            bFilter: false,
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");

}
dashboard.getWarn = function() {
    $.get("sh/warn.php", function(data) {
        var table = $("#warn_dashboard");
        var ex = document.getElementById("warn_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }
        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "message" }
            ],
            bPaginate: false,
            bFilter: false,
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}

dashboard.getRam = function() {
    $.get("sh/mem.php", function(data) {
        var ram_total = data[1];
        var ram_used = Math.round((data[4] / ram_total) * 100);
        var ram_free = Math.round((data[5] / ram_total) * 100);
        var ram_buffer = Math.round((data[2] / ram_total) * 100);
        var ram_cache = Math.round((data[3] / ram_total) * 100);

        $("#ram-total").text(ram_total);
        $("#ram-used").text(data[4]);
        $("#ram-free").text(data[5]);
        $("#ram-cache").text(data[3]);
        $("#ram-buffer").text(data[2]);

        $("#ram-free-per").text(ram_free);
        $("#ram-used-per").text(ram_used);
        $("#ram-buffer-per").text(ram_buffer);
        $("#ram-cache-per").text(ram_cache);
    }, "json");
}

dashboard.getDf = function() {
    $.get("sh/df.php", function(data) {
        var table = $("#df_dashboard");
        var ex = document.getElementById("df_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }

        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "Device" },
                { sTitle: "Size", },
                { sTitle: "Used", },
                { sTitle: "Avail",},
                { sTitle: "Use%",},
                { sTitle: "Mounted" },
                { sTitle: "Filesystem" },
                { sTitle: "Filesystem status" }
            ],
            bPaginate: false,
            bFilter: false,
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}

dashboard.getNic = function() {
    $.get("sh/nic.php", function(data) {
        var table = $("#nic_dashboard");
        var ex = document.getElementById("nic_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }

        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "Name" },
                { sTitle: "Speed"},
                { sTitle: "duplex"},
                { sTitle: "port"},
                { sTitle: "Negotiation"},
                { sTitle: "link" },
                { sTitle: "ip" },
                { sTitle: "Mac Address" }
            ],
            bPaginate: false,
            bFilter: false,
            aaSorting: [[5, "desc"]],
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}

dashboard.getBondS= function() {
    $.get("sh/bond_status.php", function(data) {
        var table = $("#bondS_dashboard");
        var ex = document.getElementById("bondS_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }

        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "bond name" },
                { sTitle: "mode"},
                { sTitle: "active Nic"},
                { sTitle: "polling interval"},
                { sTitle: "ip"}
            ],
            bPaginate: false,
            bFilter: false,
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}
dashboard.getBond= function() {
    $.get("sh/bond.php", function(data) {
        var table = $("#bond_dashboard");
        var ex = document.getElementById("bond_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }

        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "bond name" },
                { sTitle: "slave nic"},
                { sTitle: "fail count"},
                { sTitle: "mac address"}
            ],
            bPaginate: false,
            bFilter: false,
            bAutoWidth: true,
            bInfo: false
        }).fadeIn();
    }, "json");
}

dashboard.getRoute= function() {
    $.get("sh/route.php", function(data) {
        var table = $("#route_dashboard");
        var ex = document.getElementById("route_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }

        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "destination" },
                { sTitle: "gateway"},
                { sTitle: "genmask"},
                { sTitle: "flags"},
                { sTitle: "metric"},
                { sTitle: "ref"},
                { sTitle: "use"},
                { sTitle: "iface"}
            ],
            bPaginate: false,
            bFilter: false,
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}

dashboard.getDaemon= function() {
    $.get("sh/daemon.php", function(data) {
        var table = $("#Daemon_dashboard");
        var ex = document.getElementById("Daemon_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }

        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "Name" },
                { sTitle: "init 0" },
                { sTitle: "init 1" },
                { sTitle: "init 2" },
                { sTitle: "init 3" },
                { sTitle: "init 4" },
                { sTitle: "init 5" },
                { sTitle: "init 6" }
            ],
            bPaginate: false,
            bFilter: false,
            aaSorting: [[0, "asc"]],
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}

dashboard.getIndex= function() {
    $.get("sh/index.php", function(data) {
        var table = $("#index_dashboard");
        var ex = document.getElementById("index_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }

        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "Hostname" },
                { sTitle: "Os" },
                { sTitle: "kernel" },
                { sTitle: "Arch" },
                { sTitle: "cpu" },
                { sTitle: "total memory" },
                { sTitle: "used memory" },
                { sTitle: "used memory %" },
                { sTitle: "uptime" },
                { sTitle: "kdump" },
                { sTitle: "Daemon enable" },
                { sTitle: "warning" },
                { sTitle: "fail" },
                { sTitle: "error" }
            ],
            bPaginate: false,
            bFilter: false,
            aaSorting: [[0, "asc"]],
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}


dashboard.getSysctl = function() {
    $.get("sh/sysctl.php", function(data) {
        var table = $("#sysctl_dashboard");
        var ex = document.getElementById("sysctl_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }

        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "Parameter" },
                { sTitle: "value" }
            ],
            bPaginate: false,
            bFilter: false,
            aaSorting: [[0, "asc"]],
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}

dashboard.getWhereIs = function() {
    $.get("sh/where.php", function(data) {
        var table = $("#whereis_dashboard");
        var ex = document.getElementById("whereis_dashboard");
        if ($.fn.DataTable.fnIsDataTable(ex)) {
            table.hide().dataTable().fnClearTable();
            table.dataTable().fnDestroy();
        }

        table.dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "Software" },
                { sTitle: "Installation" }
            ],
            bPaginate: false,
            bFilter: false,
            aaSorting: [[1, "desc"]],
            bAutoWidth: false,
            bInfo: false
        }).fadeIn();
    }, "json");
}

dashboard.getOs = function() {
    generate_os_data("sh/issue.php", "#os-info");
    generate_os_data("sh/hostname.php", "#os-hostname");
    generate_os_data("sh/uptime.php", "#os-uptime");
    generate_os_data("sh/kernel.php", "#os-kernel");
    generate_os_data("sh/numberofcores.php", "#core-number");
    generate_os_data("sh/corename.php", "#core-model");
    generate_os_data("sh/grub.php", "#os-boot");
    generate_os_data("sh/arch.php", "#os-arch");
    generate_os_data("sh/comment.php", "#comment_dashboard");
}

dashboard.getIp = function() {
    $.get("sh/ip.php", function(data) {
        destroy_dataTable("ip_dashboard");
        $("#ip_dashboard").dataTable({
            aaData: data,
            aoColumns: [
                { sTitle: "Interface" },
                { sTitle: "IP" }
            ],
			iDisplayLength: 5,
			bPaginate: true,
            sPaginationType: "two_button",
            bFilter: false,
            bAutoWidth: true,
            bInfo: false
        }).fadeIn();
    }, "json");
}

dashboard.getIspeed = function() {
    var rate = $("#ispeed-rate");

    // 0 = KB
    // 1 = MB
    var AS = 0;
    var power = AS+1;
    var result = 0;

    $.get("sh/speed.php", function(data) {
        // round the speed (float to int);
        // dependent on value of AS, calculate speed in MB or KB ps
        result = Math.floor((data/(Math.pow(1024,power))));
        // update rate of speed on widget
        rate.text(result);

    });
    // update unit value in widget
    var lead = rate.next(".lead");
    lead.text(AS ? "MB/s" : "KB/s");
}

dashboard.getLoadAverage = function() {
    $.get("sh/loadavg.php", function(data) {
        $("#cpu-1min").text(data[0][0]);
        $("#cpu-5min").text(data[1][0]);
        $("#cpu-15min").text(data[2][0]);
        $("#cpu-1min-per").text(data[0][1]);
        $("#cpu-5min-per").text(data[1][1]);
        $("#cpu-15min-per").text(data[2][1]);
    }, "json");
}

dashboard.getNumberOfCores = function() {
    generate_os_data("sh/numberofcores.php", "#core-number");
    generate_os_data("sh/corename.php", "#core-model");
}

/**
 * Refreshes all widgets. Does not call itself recursively.
 */
dashboard.getAll = function() {
    for (var item in dashboard.fnMap) {
        if (dashboard.fnMap.hasOwnProperty(item) && item !== "all") {
            dashboard.fnMap[item]();
        }
    }
}

dashboard.fnMap = {
    all: dashboard.getAll,
    ram: dashboard.getRam,
    ps: dashboard.getPs,
    df: dashboard.getDf,
    nic: dashboard.getNic,
    sysctl: dashboard.getSysctl,
    bondS: dashboard.getBondS,
    bond: dashboard.getBond,
    route: dashboard.getRoute,
    daemon: dashboard.getDaemon,
    os: dashboard.getOs,
    loadaverage: dashboard.getLoadAverage,
    error: dashboard.getError,
    warn: dashboard.getWarn,
    fail: dashboard.getFail,
    kdump: dashboard.getKdump,
    index: dashboard.getIndex,
    netstat: dashboard.getNetstat
};

