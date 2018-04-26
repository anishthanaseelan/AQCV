package FileSql;

#########################################################################################
# Functions
#
# Sql Statements
# ---------------------------------------------------------------------------------------
#
# getSqlStatements:			receives a reference to an array of code
#								*(optional reference to getSqlInfo array)
#							returns a reference to an array of sql statements
#
# getSqlSelectStatements:	receives a reference to an array of code
#								*(optional reference to getSqlInfo array)
#							returns a reference to an array of sql select statements
#
# getSqlInsertStatements:	receives a reference to an array of code
#								*(optional reference to getSqlInfo array)
#							returns a reference to an array of sql insert statements
#
# getSqlUpdateStatements:	receives a reference to an array of code
#								*(optional reference to getSqlInfo array)
#							returns a reference to an array of sql update statements
#
# getSqlDeleteStatements:	receives a reference to an array of code
#								*(optional reference to getSqlInfo array)
#							returns a reference to an array of sql delete statements
#
# getSqlLineNumber:			receives a reference to an array of code and a sql statement
#								*(optional reference to getSqlInfo array)
#							returns the start and end lines of the sql statement #~#
#							(the line numbers will be based on the functions position with the array)
#
# getSqlLineNumbers:		receives a reference to an array of code
#								*(optional reference to getSqlInfo array)
#							returns a reference to an arry of the start and end lines of the sql statement #~#
#							(the line numbers will be based on the functions position with the array)
#
# getSqlInfo:				receives a reference to an array of code
#							returns a reference to an array of sql statement info (~ delimited)
#							1) sql statement
#							2) start line
#							3) end line
#
# Sql Exec
# ---------------------------------------------------------------------------------------
#
# getSqlExecNames: 			receives a reference to an array of code
#								*(optional reference to getSqlExecInfo array)
#							returns a reference to an array of sql exec names
#
# getSqlExecRcvrVars:		receives a reference to an array of code and a exec name
#								*(optional reference to getSqlExecInfo array)
#							returns a reference to an array of receiver variables
#
# getSqlExecIndVars:		receives a reference to an array of code and a exec name
#								*(optional reference to getSqlExecInfo array)
#							returns a reference to an array of indicator variables
#
# getSqlExecLineNumber:		receives a reference to an array of code and a exec name
#								*(optional reference to getSqlExecInfo array)
#							return the line number of the exec statement
#
# getSqlExecInfo:			recieves a reference to an array of code
#							returns a reference to an array of sql exec info (~ delimited)
#							1) prep name
#							2) start line
#							3) Exec Sql Type
#							4) receiver variables (, delimited)
#							5) indicator variables (, delimited)
#
#
#
#########################################################################################

use FileGeneral;

############################## Sql Statement Functions ##################################

sub getSqlStatements
{
	my $codeRef 				= shift;
	my $passedSqlInfoRef 		= shift;
	my $sqlInfoRef = $passedSqlInfoRef || getSqlInfo($codeRef);
	my @sqlStatements = ();
	foreach my $sql (@$sqlInfoRef)
	{
		my @info = split(/~/, $sql);
		push (@sqlStatements, $info[0]);
	}
	return \@sqlStatements;
}

sub getSqlSelectStatements
{
	my $codeRef 				= shift;
	my $passedSqlInfoRef 		= shift;
	my $sqlInfoRef = $passedSqlInfoRef || getSqlInfo($codeRef);
	my @sqlStatements = ();
	foreach my $sql (@$sqlInfoRef)
	{
		my @info = split(/~/, $sql);
		if (uc(substr($info[0], 0, index($info[0], " "))) eq "SELECT")
		{
			push (@sqlStatements, $info[0]);
		}
	}
	return \@sqlStatements;
}

sub getSqlInsertStatements
{
	my $codeRef 				= shift;
	my $passedSqlInfoRef 		= shift;
	my $sqlInfoRef = $passedSqlInfoRef || getSqlInfo($codeRef);
	my @sqlStatements = ();
	foreach my $sql (@$sqlInfoRef)
	{
		my @info = split(/~/, $sql);
		if (uc(substr($info[0], 0, index($info[0], " "))) eq "INSERT")
		{
		push (@sqlStatements, $info[0]);
		}
	}
	return \@sqlStatements;
}

sub getSqlUpdateStatements
{
	my $codeRef 				= shift;
	my $passedSqlInfoRef 		= shift;
	my $sqlInfoRef = $passedSqlInfoRef || getSqlInfo($codeRef);
	my @sqlStatements = ();
	foreach my $sql (@$sqlInfoRef)
	{
		my @info = split(/~/, $sql);
		if (uc(substr($info[0], 0, index($info[0], " "))) eq "UPDATE")
		{
			push (@sqlStatements, $info[0]);
		}
	}
	return \@sqlStatements;
}

sub getSqlDeleteStatements
{
	my $codeRef 				= shift;
	my $passedSqlInfoRef 		= shift;
	my $sqlInfoRef = $passedSqlInfoRef || getSqlInfo($codeRef);
	my @sqlStatements = ();
	foreach my $sql (@$sqlInfoRef)
	{
		my @info = split(/~/, $sql);
		if (uc(substr($info[0], 0, index($info[0], " "))) eq "DELETE")
		{
			push (@sqlStatements, $info[0]);
		}
	}
	return \@sqlStatements;
}

sub getSqlLineNumber
{
	my $codeRef 				= shift;
	my $targetSql 				= shift;
	my $passedSqlInfoRef 		= shift;
	my $sqlInfoRef = $passedSqlInfoRef || getSqlInfo($codeRef);
	my $lineStart = 0;
	my $lineEnd = 0;
	foreach my $sql (@$sqlInfoRef)
	{
		my @info = split(/~/, $sql);
		if ($info[0] eq $targetSql)
		{
		$lineStart = $info[1];
		$lineEnd = $info[2];
		last;
		}

	}
	return $lineStart . "~" . $lineEnd;
}

sub getSqlLineNumbers
{
	my $codeRef 				= shift;
	my $passedSqlInfoRef 		= shift;
	my $sqlInfoRef = $passedSqlInfoRef || getSqlInfo($codeRef);
	my @sqlLineNumbers = ();
	foreach my $sql (@$sqlInfoRef)
	{
		my @info = split(/~/, $sql);
		my $data = $info[1] . "~" . $info[2];
		push (@sqlLineNumbers, $data);
	}
	return \@sqlLineNumbers;
}

sub getSqlInfo
{
	my $codeRef 				= shift;
	my $codeRef = FileGeneral::removeComments($codeRef);
	my @code = @$codeRef;
	my $isInStatement = 0;
	my @sqlStatements = ();
	my $statement = "";
	my $lineCurrent = 0;
	my $lineStart = 0;
	my $lineEnd = 0;
	foreach my $line (@code)
	{
		chomp($line);
		$lineCurrent++;
		my $isFirstLine = 0;
		$statement =~ s/\t/ /g;
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		if ($line =~ m/\"/ && $isInStatement == 0)
		{
			my $tmpLine = substr($line, index($line, "\"") + 1, length($line) - index($line, "\""));
			$tmpLine = substr($tmpLine, 0, index($tmpLine, "\""));
			$tmpLine =~ s/^\s+//;
			$tmpLine =~ s/\s+$//;
			$tmpLine .= " ";
			foreach (sqlCommands())
			{
				if (uc($tmpLine) =~ m/^$_ /)
				{
					#print "$lineCurrent: $tmpLine\n";
					$lineStart = $lineCurrent;
					$isInStatement = 1;
					$statement .= $tmpLine;
					$isFirstLine = 1;
				}
			}
		}
		elsif ($isInStatement == 1 && $line =~ m/;$/)
		{
			$line = substr($line, index($line, "\"") + 1, length($line) - index($line, "\""));
			$line = substr($line, 0, index($line, "\""));
			$line =~ s/^\s+//;
			$line =~ s/\s+$//;
			$lineEnd = $lineCurrent;
			$isInStatement = 0;
			$statement .= " " . $line;
			$statement .= "~" . $lineStart . "~" . $lineEnd;
			$statement =~ s/\t/ /g;
			$statement =~ s/[ ]+/ /g;
			push (@sqlStatements, $statement);
			$statement = "";

		}
		elsif ($isInStatement == 1)
		{
			my $parenCount = ($line =~ tr/\"//);
			if ($parenCount == 2)
			{
				$line = substr($line, index($line, "\"") + 1, length($line) - index($line, "\""));
				$line = substr($line, 0, index($line, "\""));
			}
			else
			{
				$line = substr($line, 0, index($line, "\""));
			}
			$line =~ s/^\s+//;
			$line =~ s/\s+$//;

			$statement .= " " . $line;
		}
		if ($isFirstLine && $line =~ m/;$/)
		{
			$statement =~ s/^\s+//;
			$statement =~ s/\s+$//;
			$statement .= "~" . $lineCurrent . "~" . $lineCurrent;
			push (@sqlStatements, $statement);
			$isInStatement = 0;
			$statement = "";
		}

	}
	return \@sqlStatements;
}

# These are key indicators to finding sql statements
sub sqlCommands
{
	return ("SELECT", "UPDATE", "INSERT", "DELETE", "CREATE TEMP TABLE", "DROP TABLE", "CREATE INDEX");
}

sub sqlReservedWords
{
	my @reservedWords = sqlCommands();
	push (@reservedWords, "SET");
	push (@reservedWords, "FROM");
	push (@reservedWords, "WHERE");
	push (@reservedWords, "AND");
	return @reservedWords;
}

sub stripSqlLine
{
	my $line = shift;
	$line =~ s/^\s+//;
	$line =~ s/\s+$//;
	$line =~ s/^\"//g;
	$line =~ s/\"$//g;
	$line =~ s/\\n//g;
	$line =~ s/[ ]+/ /g;
	return $line;
}

################################## Sql Exec Functions ###################################

sub getSqlExecNames
{
	my $codeRef 				= shift;
	my $type					= shift; # optional
	my $passedExecInfoRef 		= shift; # optional
	my $sqlExecInfoRef = $passedExecInfoRef || getSqlExecInfo($codeRef);
	my @sqlExecNames = ();
	foreach my $sqlExec (@$sqlExecInfoRef)
	{
		my @info = split(/~/, $sqlExec);
		if ((uc($type) eq $info[2] || !$type) && $info[0])
		{
			push (@sqlExecNames, $info[0]);
		}
	}
	return \@sqlExecNames;
}

sub getSqlExecLineNumber
{
	my $codeRef 				= shift;
	my $targetName 				= shift;
	my $type					= shift; # optional
	my $passedExecInfoRef 		= shift; # optional
	my $lineNumber = 0;
	my $sqlExecInfoRef = $passedExecInfoRef || getSqlExecInfo($codeRef);
	foreach my $sqlExec (@$sqlExecInfoRef)
	{
		my @info = split(/~/, $sqlExec);
		if (($info[0] eq $targetName) && ($info[2] eq uc($type) || !$type))
		{
			$lineNumber = $info[1];
			last;
		}
	}
	return $lineNumber;
}

sub getSqlExecType
{
	my $codeRef 				= shift;
	my $targetName 				= shift;
	my $passedExecInfoRef 		= shift; # optional
	my $type;
	my $sqlExecInfoRef = $passedExecInfoRef || getSqlExecInfo($codeRef);
	foreach my $sqlExec (@$sqlExecInfoRef)
	{
		my @info = split(/~/, $sqlExec);
		if ($info[0] eq $targetName)
		{
			$type = $info[2];
			last;
		}
	}
	return $type;
}

sub getSqlExecRcvrVars
{
	my $codeRef 				= shift;
	my $targetName 				= shift;
	my $passedExecInfoRef 		= shift; #optional
	my @sqlExecVars = ();
	my $sqlExecInfoRef = $passedExecInfoRef || getSqlExecInfo($codeRef);
	foreach my $sqlExec (@$sqlExecInfoRef)
	{
		my @info = split(/~/, $sqlExec);
		if ($info[0] eq $targetName)
		{
			my @vars = split(/,/, $info[3]);
			foreach (@vars)
			{
				$_ =~ s/^\s+//;
				$_ =~ s/\s+$//;
				push (@sqlExecVars, $_);
			}
			last;
		}
	}
	return \@sqlExecVars;
}

sub getSqlExecIndVars
{
	my $codeRef 				= shift;
	my $targetName 				= shift;
	my $passedExecInfoRef 		= shift; #optional
	my @sqlExecVars = ();
	my $sqlExecInfoRef = $passedExecInfoRef || getSqlExecInfo($codeRef);
	foreach my $sqlExec (@$sqlExecInfoRef)
	{
		my @info = split(/~/, $sqlExec);
		if ($info[0] eq $targetName)
		{
			my @vars = split(/,/, $info[4]);
			foreach (@vars)
			{
				$_ =~ s/^\s+//;
				$_ =~ s/\s+$//;
				push (@sqlExecVars, $_);
			}
			last;
		}
	}
	return \@sqlExecVars;
}

sub getSqlExecInfo
{
	my $codeRef 				= shift;
	$codeRef = FileGeneral::concatLines($codeRef);
	my @prepLines = ();
	my $lineCurrent = 0;
	foreach my $line (@$codeRef)
	{
		chomp($line);
		#$line = uc($line);
		$lineCurrent++;
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		if ($line =~ m/^EXEC SQL/)
		{
			#print "$line\n";
			$line =~ s/^EXEC SQL //;
			my $type;
			if ($line =~ m/^PREPARE/)							{ $type = "PREPARE";		$line =~ s/^PREPARE//;						}
			elsif ($line =~ m/^DECLARE/)						{ $type = "DECLARE";		$line =~ s/^DECLARE//;						}
			elsif ($line =~ m/^EXECUTE/)						{ $type = "EXECUTE";		$line =~ s/^EXECUTE//;						}
			elsif ($line =~ m/^FETCH/)							{ $type = "FETCH"; 			$line =~ s/^FETCH//;						}
			elsif ($line =~ m/^OPEN/)							{ $type = "OPEN";			$line =~ s/^OPEN//;							}
			elsif ($line =~ m/^CLOSE/)							{ $type = "CLOSE";			$line =~ s/^CLOSE//;						}
			elsif ($line =~ m/^BEGIN WORK/)						{ $type = "BEGIN WORK";		$line =~ s/^BEGIN WORK//;					}
			elsif ($line =~ m/^COMMIT WORK/)					{ $type = "COMMIT WORK";	$line =~ s/^COMMIT WORK//;					}
			elsif ($line =~ m/^ROLLBACK WORK/)					{ $type = "ROLLBACK WORK";	$line =~ s/^ROLLBACK WORK//;				}
			elsif ($line =~ m/^BEGIN DECLARE SECTION/)			{ $type = "BEGIN DECLARE";	$line =~ s/^BEGIN DECLARE SECTION//;		}
			elsif ($line =~ m/^END DECLARE SECTION/)			{ $type = "END DECLARE";	$line =~ s/^END DECLARE SECTION//;			}
			elsif ($line =~ m/^INCLUDE/)						{ $type = "INCLUDE";		$line =~ s/^INCLUDE//; $line =~ s/\"//g;	}
			elsif ($line =~ m/^FREE/)							{ $type = "FREE";			$line =~ s/^FREE//;							}
			elsif ($line =~ m/^SET ISOLATION TO DIRTY READ/)	{ $type = "SET ISOLATION";	$line =~ s/^SET ISOLATION TO DIRTY READ//;	}
			elsif ($line =~ m/^CREATE TEMP TABLE/)				{ $type = "CREATE TEMP";	$line =~ s/^CREATE TEMP TABLE//;			}
			elsif ($line =~ m/^DATABASE/)						{ $type = "DATABASE";		$line =~ s/^DATABASE//;						}
			else												{ $type = "OTHER";														}
			$line =~ s/^\s+//;
			$line =~ s/\s+$//;
			$line =~ s/;$//;
			$line =~ s/\://g;

			my ($prepName, $cursorName, $receiverVar, $indicatorVar);
			if ($line =~ m/INTO/ && $line =~ m/USING/) # Execute
			{
				($prepName, $line) = split(/INTO/, $line);
				($receiverVar, $indicatorVar) = split(/USING/, $line);
			}
			elsif ($line =~ m/INTO/) # Execute, Fetch
			{
				($prepName, $receiverVar) = split(/INTO/, $line);
			}
			elsif ($line =~ m/USING/) # Execute, Open
			{
				($prepName, $indicatorVar) = split(/USING/, $line);
			}
			elsif ($line =~ m/FROM/) # Prepare
			{
				($prepName, undef) = split(/FROM/, $line);

			}
			elsif ($line =~ m/CURSOR FOR/) # Delare
			{
				($cursorName, $prepName) = split(/CURSOR FOR/, $line);
			}
			else # Close, Begin Work, Commit Work, Rollback Work, Begin Declare, End Declare, Free
			{
				$prepName = $line;
			}
			foreach ($prepName, $cursorName, $receiverVar, $indicatorVar)
			{
				$_ =~ s/^\s+//;
				$_ =~ s/\s+$//;
			}
			# This if test is a hack to eliminate the lower case versions of using that got past the previous splits.  see rule 16.
			if (uc($prepName) !~ /USING/)
			{
				my $info = $prepName . "~" . $lineCurrent . "~" . $type . "~" . $cursorName . "~" . $receiverVar . "~" . $indicatorVar;
				#print "$info\n";
				push(@prepLines, $info);
			}
		}
	}
	return \@prepLines;
}

sub xrefSqlPrepInfo
{
	my $sqlInfoRef 				= shift;
	my $execInfoRef 			= shift;

	my @sqlPrepXref = ();

	my @preps = ();
	foreach my $line (@$execInfoRef)
	{
		my @vars = split (/~/, $line);
		if ($vars[2] eq "PREPARE")
		{
			push (@preps, $line);
		}
	}

	my @sqls = @$sqlInfoRef;

	my $sqlCount = @sqls;
	my $prepCount = @preps;

	if ($sqlCount >= $prepCount)
	{
		foreach my $execInfo (@preps)
		{
			my @execVars = split(/~/, $execInfo);
			my $execLine = $execVars[1];
			for (my $i = $sqlCount - 1; $i >= 0; $i--)
			{
				my @sqlVars = split(/~/, $sqls[$i]);
				my $sqlLineStart = $sqlVars[1];
				my $sqlLineEnd = $sqlVars[2];
				if ($execLine > $sqlLineEnd)
				{
					my $data = $sqlVars[0] . "~" . $sqlVars[1] . "~" . $execVars[0] . "~" . $execVars[1];
					push (@sqlPrepXref, $data);
					last;
				}
			}
		}
	}
	return \@sqlPrepXref;
}


1;
