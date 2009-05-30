use MooseX::Declare;

role Golf::Domain::Meta::ID 
with KiokuDB::Role::ID {
    requires 'id';
    method kiokudb_object_id {
        $self->id;
    };
};