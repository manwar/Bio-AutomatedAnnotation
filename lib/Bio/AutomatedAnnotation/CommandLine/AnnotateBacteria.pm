package Bio::AutomatedAnnotation::CommandLine::AnnotateBacteria;

# ABSTRACT: provide a commandline interface to the annotation wrappers

=head1 SYNOPSIS

provide a commandline interface to the annotation wrappers

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::AutomatedAnnotation;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'sample_name'       => ( is => 'rw', isa => 'Str'  );
has 'dbdir'             => ( is => 'rw', isa => 'Str', default => '/lustre/scratch108/pathogen/pathpipe/prokka'  );
has 'assembly_file'     => ( is => 'rw', isa => 'Str'  );
has 'annotation_tool'   => ( is => 'rw', isa => 'Str', default  => 'Prokka' );
has 'tmp_directory'     => ( is => 'rw', isa => 'Str', default  => '/tmp' );
has 'sequencing_centre' => ( is => 'rw', isa => 'Str', default  => 'SC' );
has 'accession_number'  => ( is => 'rw', isa => 'Maybe[Str]' );
has 'genus'             => ( is => 'rw', isa => 'Str' );
has 'kingdom'           => ( is => 'rw', isa => 'Str', default  => 'Bacteria' );
has 'cpus'              => ( is => 'rw', isa => 'Int', default  => 1);
has 'gcode'             => ( is => 'ro', isa => 'Int', default  => 11 );

sub BUILD {
    my ($self) = @_;

    my ( $sample_name, $kingdom, $dbdir, $assembly_file, $annotation_tool, $tmp_directory, $sequencing_centre, $accession_number,$genus, $cpus, $gcode,
        $help );

    GetOptionsFromArray(
        $self->args,
        's|sample_name=s'       => \$sample_name,
        'd|dbdir=s'             => \$dbdir,
        'a|assembly_file=s'     => \$assembly_file,
        't|tmp_directory=s'     => \$tmp_directory,
        'p|annotation_tool=s'   => \$annotation_tool,
        'c|sequencing_centre=s' => \$sequencing_centre,
        'g|genus=s'             => \$genus,
        'k|kingdom=s'           => \$kingdom,
        'i|cpus=s'              => \$cpus,
        'n|accession_number=s'  => \$accession_number,
        'h|help'                => \$help,
        'gcode=i'               => \$gcode,
    );

    $self->sample_name($sample_name)             if ( defined($sample_name) );
    $self->dbdir($dbdir)                         if ( defined($dbdir) );
    $self->assembly_file($assembly_file)         if ( defined($assembly_file) );
    $self->annotation_tool($annotation_tool)     if ( defined($annotation_tool) );
    $self->tmp_directory($tmp_directory)         if ( defined($tmp_directory) );
    $self->sequencing_centre($sequencing_centre) if ( defined($sequencing_centre) );
    $self->accession_number($accession_number)   if ( defined($accession_number) );
    $self->genus($genus)                         if ( defined($genus) );
    $self->kingdom($kingdom)                     if ( defined($kingdom) );
    $self->cpus($cpus)                           if ( defined($cpus) );
    $self->gcode($gcode)                         if ( defined($gcode) );
}

sub run {
    my ($self) = @_;
    (( -e $self->assembly_file ) && ! $self->help ) or die $self->usage_text;

    my $obj = Bio::AutomatedAnnotation->new(
          assembly_file    => $self->assembly_file,
          annotation_tool  => $self->annotation_tool,
          sample_name      => $self->sample_name,
          accession_number => $self->accession_number,
          dbdir            => $self->dbdir,
          tmp_directory    => $self->tmp_directory,
          genus            => $self->genus,
          kingdom          => $self->kingdom,
          cpus             => $self->cpus,
          gcode            => $self->gcode,
    );
    $obj->annotate;

}

sub usage_text {
      my ($self) = @_;
      my $script_name = $self->script_name;

      return <<USAGE;
    Usage: $script_name [options]
    Annotate bacteria with Prokka
    
    Seemann T. Prokka: rapid prokaryotic genome annotation. Bioinformatics. 2014 Jul 15;30(14):2068-9. PMID:24642063
    
    # Annotate a bacteria with a genus specific database (recommended usage)
    $script_name -a contigs.fa  --sample_name Sample123  --genus Klebsiella
    
    # Annotate a bacteria without a genus specific database
    $script_name -a contigs.fa  --sample_name Sample123
    
    # Use multiple processors (faster)
    $script_name -a contigs.fa  --sample_name Sample123 --cpus 10

    # Use a different translation table (defaults to 11)
    $script_name -a contigs.fa  --sample_name Sample123 --gcode 4

    # Annotate a virus - unvalidated
    $script_name -a contigs.fa  --sample_name Sample123  --kingdom Viruses
    
    # This help message
    annotate_bacteria -h
    
    This software uses Prokka by Torsten Seemann
    http://bioinformatics.net.au/prokka-manual.html
    
    The databases are searched in the following order:
    
      Genus specific RefSeq databases (optional)
      UniprotKB - bacteria/viruses only
      Clusters 
      Conserved domain database
      tigrfams
      pfam (A)
      rfam

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
