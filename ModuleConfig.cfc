component {
    this.name = "ip";
    this.author = "Ryan Albrecht";
    this.webUrl = "https://github.com/ryanalbrecht/ip";
    this.dependencies = [ ];

    function configure() {
        binder.map("ip@ip").to("#moduleMapping#.ip");
        binder.map("ipv4@ip").to("#moduleMapping#.ipv4");
        binder.map("ip@v6ip").to("#moduleMapping#.ipv6");
    }

    function onLoad() {

    }
}