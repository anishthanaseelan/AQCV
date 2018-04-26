package FileGeneral;

#########################################################################################
# Functions
#
# removeComments:			receives a reference to an array of code
#							returns a reference to an array of code free of comments
#
# concatLines:				receives a reference to an array of code
#							returns a reference to an array of code free of comments
#							and without line returns in the middle of executable lines
#
#########################################################################################

sub removeComments
{
	my $codeRef = shift;
	my @code = @$codeRef;
	my @strippedCode = ();
	my $isInComment = 0;
	foreach my $line (@code)
	{
		if ($line =~ m/\/\//)
		{
			#print "$line\n";
			my $startIndex = index($line, "\/\/");
			my $line = substr($line, 0, $startIndex);
			my $rawLine = $line;
			$line =~ s/\s+$//;
			if (length($line) > 0) { push (@strippedCode, $rawLine); }
			else { push (@strippedCode, "\n"); }
		}
		elsif ($line =~ m/\/\*/)
		{
			$isInComment = 1;
			my $startIndex = index($line, "\/\*");
			if ($line =~ m/\*\//)
			{
				$isInComment = 0;
				my $endIndex = index($line, "\*\/");
				my $line = substr($line, 0, $startIndex) . substr($line, $endIndex + 2, length($line));
				my $rawLine = $line;
				$line =~ s/\s+$//;
				if (length($line) > 0) { push (@strippedCode, $rawLine); }
				else { push (@strippedCode, "\n"); }
			}
			else
			{
				push (@strippedCode, "\n");
			}
		}
		elsif ($line =~ m/\*\// && $isInComment == 1)
		{
			$isInComment = 0;
			my $endIndex = index($line, "\*\/");
			my $line = substr($line, $endIndex + 2, length($line));
			my $rawLine = $line;
			$line =~ s/\s+$//;
			if (length($line) > 0) { push (@strippedCode, $rawLine); }
			else { push (@strippedCode, "\n"); }
		}
		elsif ($isInComment == 0)
		{
			push (@strippedCode, $line);
		}
		else
		{
			push (@strippedCode, "\n");
		}
	}
	return \@strippedCode;
}

sub concatLines
{
	my $codeRef = shift;
	my $codeRef = removeComments($codeRef);
	my @code = @$codeRef;
	my $tmpLine = "";
	my $concats = 0;
	my @strippedCode = ();
	my $isInExec = 0;
	foreach my $line (@code)
	{
		$line =~ s/\s+$//;
		my $strippedLine = $line;
		$strippedLine =~ s/^\s+//;
		if ($strippedLine =~ m/^EXEC/ || $isInExec)
		{
			$isInExec = 1;
			if ($line =~ m/;$/)
			{
				$line =~ s/^\s+//;
				$tmpLine .= " " . $line;
				$line = $tmpLine;
				$line = $line . "\n";
				push (@strippedCode, $line);
				for (my $i = 1; $i <= $concats; $i++) { push (@strippedCode, "\n"); }
				$tmpLine = "";
				$concats = 0;
				$isInExec = 0;
			}
			else
			{
				if ($concats > 0) { $line =~ s/^\s+//; }
				$tmpLine .= " " . $line;
				$concats++;
			}
		}
		elsif ($line =~ m/,$/ || $line =~ m/\"$/)
		{
			if ($concats > 0) { $line =~ s/^\s+//; }
			$tmpLine .= " " . $line;
			$concats++;
		}
		elsif ($tmpLine)
		{
			$line =~ s/^\s+//;
			$tmpLine .= " " . $line;
			$line = $tmpLine;
			$line = $line . "\n";
			push (@strippedCode, $line);
			for (my $i = 1; $i <= $concats; $i++) { push (@strippedCode, "\n"); }
			$tmpLine = "";
			$concats = 0;
		}
		else
		{
			$line = $line . "\n";
			push (@strippedCode, $line);
		}
	}
	return \@strippedCode;
}

1;