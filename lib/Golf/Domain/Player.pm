use MooseX::Declare;

class Golf::Domain::Player with KiokuX::User with Golf::Domain::Meta::Extractable {
    use KiokuX::User::Util qw/crypt_password/;
    has 'name' => (
        traits => [qw/Extract/],
        is => 'rw', 
        isa => 'Str', 
        required => 0
    );
    
}