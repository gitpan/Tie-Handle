
##  Copyright (c) 1997 by Steffen Beyer. All rights reserved.
##  This package is free software; you can redistribute and/or
##  modify it under the same terms as Perl itself.

require 5.004;

package Tie::Handle;

use strict;

use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION $AUTOLOAD);

require Exporter;

@ISA = qw(Exporter);

@EXPORT = qw();

@EXPORT_OK = qw();

$VERSION = "1.0";

sub AUTOLOAD
{
   croak "$AUTOLOAD(): method not implemented";
}

sub tie
{
    croak "Usage: \$object->tie({'FILEHANDLE',\$filehandle});"
      if (@_ != 2);

    my($object,$filehandle) = @_;

    if (ref($filehandle))  ##  file handle reference
    {
        if (ref($filehandle) !~ /^(?:File|IO::)Handle$/)
        {
            croak
  "Tie::Handle::tie(): not a 'FileHandle' or 'IO::Handle' object reference";
        }
    }
    else                   ##  symbolic file handle
    {
        $filehandle = caller() . '::' . $filehandle
          unless ($filehandle =~ /::|^STD(?:IN|OUT|ERR)$/);
    }
    no strict "refs";
    tie(*{$filehandle}, 'Tie::Handle', $object);
    use strict "refs";
}

sub TIEHANDLE
{
    croak "Usage: tie(*{\$filehandle}, 'Tie::Handle', \$object);"
      if (@_ != 2);

    shift;
    my($object) = shift;
    my($proxy);

    if (ref($object) &&
       (ref($object) !~ /^SCALAR$|^ARRAY$|^HASH$|^CODE$|^REF$/))
    {
        $proxy = \$object;
        bless($proxy);
        return($proxy);
    }
    else
    {
        croak "Tie::Handle::TIEHANDLE(): not an object reference";
    }
}

sub PRINT
{
    croak "Usage: print [FILEHANDLE|\$filehandle] \@items;"
      if (@_ < 1);

    my($proxy) = shift;

    ${$proxy}->print(@_);
}

sub PRINTF
{
    croak "Usage: printf [FILEHANDLE|\$filehandle] \$format, \@items;"
      if (@_ < 2);

    my($proxy) = shift;
    my($format) = shift;

    ${$proxy}->print( sprintf($format,@_) );
}

sub READLINE
{
    croak "Usage: {\$line,\@list} = <[FILEHANDLE|\$filehandle]>;"
      if (@_ != 1);

    my($proxy) = shift;

    return( ${$proxy}->read() );
}

sub GETC
{
    croak "Usage: \$key = getc([FILEHANDLE|\$filehandle]);"
      if (@_ != 1);

    my($proxy) = shift;

    return( ${$proxy}->getchar() );
}

sub READ
{
    croak
'Usage: $bytes = [sys]read({FILEHANDLE,$filehandle},$buffer,$length[,$offset]);'
    if ((@_ < 3) || (@_ > 4));

    my($proxy) = shift;

    return( ${$proxy}->blockread(@_) );
}

sub DESTROY
{
    my($proxy) = shift;

    ${$proxy}->reset();
}

1;

__END__

=head1 NAME

Tie::Handle - tie arbitrary objects to file handles

See the module "Data::Locations" for an example of how to use
this module.

=head1 SYNOPSIS

=over 4

=item *

C<$object-E<gt>tie('FILEHANDLE');>

=item *

C<$object-E<gt>tie($filehandle);>

=item *

C<print @items;>

=item *

C<print FILEHANDLE @items;>

=item *

C<print $filehandle @items;>

=item *

C<printf $format, @items;>

=item *

C<printf FILEHANDLE $format, @items;>

=item *

C<printf $filehandle $format, @items;>

=item *

C<$line = E<lt>E<gt>;>

=item *

C<@list = E<lt>E<gt>;>

=item *

C<$line = E<lt>FILEHANDLEE<gt>;>

=item *

C<@list = E<lt>FILEHANDLEE<gt>;>

=item *

C<$line = E<lt>$filehandleE<gt>;>

=item *

C<@list = E<lt>$filehandleE<gt>;>

=item *

C<$key = getc();>

=item *

C<$key = getc(FILEHANDLE);>

=item *

C<$key = getc($filehandle);>

=item *

C<$bytes = [sys]read(FILEHANDLE,$buffer,$length[,$offset]);>

=item *

C<$bytes = [sys]read($filehandle,$buffer,$length[,$offset]);>

=back

=head1 DESCRIPTION

This module facilitates the tying of file handles with (arbitrary)
objects.

File handles must be given either as symbolic file handles (like "STDOUT")
or as references as returned by the "new()" method of the "IO::Handle"
or "FileHandle" class (either works).

Your class "Your::Class" needs to:

  require Tie::Handle;

and to add "Tie::Handle" to the list of classes to inherit from:

  @ISA = qw(Exporter Tie::Handle);

in order to enable tying of file handles with objects of "Your::Class".

Note that your class "Your::Class" is also responsible for providing
(i.e., overloading) the appropriate methods needed for writing to
and reading from your objects:

  "print()", "read()", "reset()", "getchar()" and "blockread()".

See the module "Data::Locations" for an example of how to implement
most of these.

Remember that you may define the default output file handle using
the Perl function "select()" so that any subsequent "print()" or
"printf()" statement without an explicit file handle will send
output to the chosen default file handle automatically!

See the section on "select()" in L<perlfunc(1)> for more details!

To dissociate the connection between a given file handle and object
(which also resets the state information usually associated with that
object which is needed to be able to read from the object line by line),
simply use one of the following statements (depending on wether you are
using symbolic file handles or file handle references):

                untie *FILEHANDLE;
                untie *{FILEHANDLE};
                untie $filehandle;
                untie *{$filehandle};

To reset an object explicitly (in order to restart reading at the
beginning, for instance), you can either call

                ${tied *FILEHANDLE}->reset();
                ${tied *{FILEHANDLE}}->reset();
                ${tied *{$filehandle}}->reset();

or directly

                $object->reset();

=head1 SEE ALSO

Data::Locations(3), perl(1), perlfunc(1),
perlsub(1), perlmod(1), perlref(1),
perlobj(1), perlbot(1), perltoot(1),
perltie(1), printf(3), sprintf(3).

=head1 VERSION

This man page documents "Tie::Handle" version 1.0.

=head1 AUTHOR

Steffen Beyer <sb@sdm.de>.

=head1 COPYRIGHT

Copyright (c) 1997 by Steffen Beyer. All rights reserved.

=head1 LICENSE

This package is free software; you can redistribute
and/or modify it under the same terms as Perl itself.

