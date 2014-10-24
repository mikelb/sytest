my $alias_localpart = "#another-alias";

test "PUT /directory/room/:room_alias creates alias",
   requires => [qw( do_request_json_authed room_id first_home_server
                    can_create_room )],

   do => sub {
      my ( $do_request_json_authed, $room_id, $first_home_server ) = @_;
      my $room_alias = "${alias_localpart}:$first_home_server";

      $do_request_json_authed->(
         method => "PUT",
         uri    => "/directory/room/$room_alias",

         content => {
            room_id => $room_id,
         },
      );
   },

   check => sub {
      my ( $do_request_json_authed, $room_id, $first_home_server ) = @_;
      my $room_alias = "${alias_localpart}:$first_home_server";

      $do_request_json_authed->(
         method => "GET",
         uri    => "/directory/room/$room_alias",
      )->then( sub {
         my ( $body ) = @_;

         json_keys_ok( $body, qw( room_id servers ));
         json_list_ok( $body->{servers} );

         $body->{room_id} eq $room_id or die "Expected room_id";

         Future->done(1);
      });
   };