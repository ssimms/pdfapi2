use ExtUtils::MakeMaker 7.12; # for XSMULTI option
 
WriteMakefile(
  NAME           => 'PDF::API2::XS',
  PREREQ_PM      => { 'ExtUtils::MakeMaker' => '7.12' },
  AUTHOR         => 'David Farrell',
  CCFLAGS        => '-Wall -std=c99',
  OPTIMIZE       => '-O3',
  LICENSE        => 'freebsd',
  XSMULTI        => 1,
);
