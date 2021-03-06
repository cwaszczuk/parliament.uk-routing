vcl 4.0;

# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
# Default backend definition.  Set this to point to your content
# server.

backend utilities {
    .host = "${UTILITIES_BACKEND_IP}";
    .port = "${UTILITIES_BACKEND_PORT}";
}

backend lists {
    .host = "${LIST_BACKEND_IP}";
    .port = "${LIST_BACKEND_PORT}";
}

backend things {
    .host = "${THING_BACKEND_IP}";
    .port = "${THING_BACKEND_PORT}";
}

sub vcl_recv {
    if(req.url == "/" || req.url ~ "^/resource" || req.url ~ "^/mps" || req.url ~ "^/meta" || req.url ~ "^/search" || req.url ~ "^/postcodes") {
        set req.backend_hint = utilities;
    } else if(req.url ~ "(people|constituencies|parties|parliaments|media)/\w{8}$") {
        set req.backend_hint = things;
    } else if(req.url ~ "^/constituencies/postcode_lookup" || req.url ~ "^/people/postcode_lookup") {
          set req.backend_hint = things;
    } else if(req.url ~ "(parliaments)/\w{8}/(previous|next)$" || req.url ~ "(parliaments/(current|next|previous))$") {
        set req.backend_hint = things;
    } else if(req.url ~ "(contituencies/map)$" || req.url ~ "(constituencies)/\w{8}/(map)$") {
        set req.backend_hint = things;
    } else if(req.url ~ "(.ico|.jpeg|.gif|.svg|.jpg|.png|.css|.js)$") {
        set req.backend_hint = utilities;
    } else {
        set req.backend_hint = lists;
    }
}
