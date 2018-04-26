package FileEc;

#########################################################################################
# FUNCTIONS
# #######################################################################################
#
# ? TODO: Change the Function and Function Prototype GetRaw functions to Info functions.
#
# VARIABLES
# ---------------------------------------------------------------------------------------
# getVariables:						receives a reference to an array of code
# 									returns a reference to an array of variable names
#										*(optional reference to getVariableInfo array)
#
# getVariableType:					receives a reference to an array of code and a variable name
#                                   returnss the variable data type
#										*(optional reference to getVariableInfo array)
#
# getVariableInitialValue:			receives a reference to an array of code and a variable name
#									returns the variables initialized value
#										*(optional reference to getVariableInfo array)
#
# getVariableInfo:					receives a reference to an array of code
# 									returns a reference to an array of variable info (~ delimited)
#									1) variable name
#									2) variable data type
#									3) variable initialized value
#									4) variable declaration line number
#
# INCLUDES
# ---------------------------------------------------------------------------------------
# getIncludesList:					recieves a reference to an array of code
#									returns a reference to a array of include directives
#
# DEFINES
# ---------------------------------------------------------------------------------------
# getDefinesList:					recieves a reference to an array of code
#									returns a reference to a array of defines
#
# FUNCTION PROTOTYPES
# ---------------------------------------------------------------------------------------
# getFunctionPrototypeList:			receives a reference to an array of code
#									returns a reference to an array of function prototypes
#
# getFunctionPrototypeReturnType:	recieves a reference to an array of code and a function name
#									returns the function return type as a string
#
# getFunctionPrototypeParms:		receives a reference to an array of code and a function name
#									returns a reference to an array of parameters
#
# getRawFunctionPrototypeLines:		receives a reference to an array of code
#									returns a reference to an array of raw function prototype lines
#
# FUNCTION
# ---------------------------------------------------------------------------------------
# ? TODO: There is a problem with the getRawFunctionLines function
# ?		If the function does not have a return type defined it does not get picked up
# ?		All other FUNCTION function use this as their basis
# ?		getRawFunctionPrototypeLines likely has the same problem
#
# getFunctionList:					receives a reference to an array of code
#									returns a reference to an array of functions
#
# getFunctionReturnType:			recieves a reference to an array of code and a function name
#									returns the function return type as a string
#
# getFunctionParms:					receives a reference to an array of code and a function name
#									returns a reference to an array of parameters
#
# getRawFunctionLines:				receives a reference to an array of code
#									returns a reference to an array of raw function lines
#
# getFunctionCode:					receives a reference to an array of code and a function name
#									returns a reference to an array of function code
#
# getFunctionLineNumbers:			recieves a reference to an array of code and a function name
#									returns the start and end lines of the function #~#
#									(the line numbers will be based on the functions position with the array)
#
# functionReturnTypes:
#									returns an array of function return types
#
#########################################################################################

use FileGeneral;

################################## Variables Functions ##################################

sub getVariables
{
	my $codeRef 				= shift;
	my $passedVariableInfoRef	= shift;
	my $variableInfoRef = $passedVariableInfoRef || getVariableInfo($codeRef);

	my @variables = ();

	foreach my $variableInfo (@$variableInfoRef)
	{
		my @info = split(/~/, $variableInfo);

		push (@variables, $info[0]);

	}
	return \@variables;
}

sub getVariableType
{
	my $codeRef 				= shift;
	my $targetVariable			= shift;
	my $passedVariableInfoRef	= shift;
	my $variableInfoRef = $passedVariableInfoRef || getVariableInfo($codeRef);

	my $variableType = 0;

	foreach my $variableInfo (@$variableInfoRef)
	{
		my @info = split(/~/, $variableInfo);
		if ($info[0] eq $targetVariable)
		{
			$variableType = $info[1];
			last;
		}

	}
	return $variableType;
}

sub getVariableInitialValue
{
	my $codeRef 				= shift;
	my $targetVariable			= shift;
	my $passedVariableInfoRef	= shift;
	$sqlInfoRef = passedVariableInfoRef || getVariableInfo($codeRef);

	my $initialValue;

	foreach my $variableInfo (@$passedVariableInfoRef)
	{
		my @info = split(/~/, $variableInfo);
		if ($info[0] eq $targetVariable)
		{
			$initialValue = $info[2];
			last;
		}

	}
	return $initialValue;
}

sub getVariableLineNumber
{
	my $codeRef 				= shift;
	my $targetVariable			= shift;
	my $passedVariableInfoRef	= shift;
	$sqlInfoRef = passedVariableInfoRef || getVariableInfo($codeRef);

	my $lineNumber = 0;

	foreach my $variableInfo (@$passedVariableInfoRef)
	{
		my @info = split(/~/, $variableInfo);
		if ($info[0] eq $targetVariable)
		{
			$lineNumber = $info[3];
			last;
		}

	}
	return $lineNumber;
}

sub getVariableInfo
{
	my $codeRef 				= shift;
	$codeRef = FileGeneral::concatLines($codeRef);
	my @code = @$codeRef;

	my @variableInfo = ();
	my $lineNumber = 0;
	foreach my $line (@code)
	{
		chomp($line);
		$lineNumber++;
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		$line =~ s/\*//g;
		$line =~ s/\t/ /g;
		foreach (variableTypes())
		{
			if ($line =~ m/^$_ / && $line =~ m/;$/)
			{
				if ($line =~ m/\(/ && $line =~ m/\)/ && $line !~ m/=/) { next; }
				my ($type, $line) = split (/ /, $line, 2);
				$line =~ s/[ ]+//g;
				$line =~ s/;$//;
				# This replaces , with ^ and = with ~ when they are inside ( )
				if ($line =~ m/\(/ && $line =~ m/\)/)
				{
					my $tmp1 = substr($line, 0, index($line, "\(") + 1);
					my $tmp2 = substr($line, index($line, "\(") + 1, length($line) - index($line, "\(") - 2);
					$tmp2 =~ s/\,/^/g;
					$tmp2 =~ s/=/~/g;
					my $tmp3 = substr($line, index($line, "\)"), length($line) - index($line, "\)"));
					$line = $tmp1 . $tmp2 . $tmp3;
				}

				my @vars1 = split (/,/, $line);
				foreach my $i (@vars1)
				{
					$i =~ s/\^/,/g;
					my @vars2 = split (/=/, $i);
					my ($var, $value);
					foreach (@vars2) { $_ =~ s/~/=/g; }
					if (@vars2 > 1)
					{
						$value = $vars2[@vars2 - 1];
					}
					else
					{
						$var = $vars2[@vars2 - 1];
						my $info = $var . "~" . $type . "~" . $value . "~" . $lineNumber;
						push (@variableInfo, $info);
					}
					for (my $j = 0; $j <= @vars2 - 2; $j++)
					{
						$var = $vars2[$j];
						my $info = $var . "~" . $type . "~" . $value . "~" . $lineNumber;
						push (@variableInfo, $info);
					}
				}
			}
		}
	}
	return \@variableInfo;
}

sub variableTypes
{
	return ("int", "gchar_c", "short", "char");
}

################################## Include Functions ####################################

sub getIncludesList
{
	my $codeRef 				= shift;
	$codeRef = FileGeneral::removeComments($codeRef);
	my @code = @$codeRef;

	my @includesList = ();
	foreach my $line (@code)
	{
		if ($line =~ m/^\#include/)
		{
			my (undef, $include) = split(/ /, $line);
			$include =~ s/^\s+//;
			$include =~ s/\s+$//;
			push (@includesList, $include);
		}
	}
	return \@includesList;
}

################################### Define Functions ####################################

sub getDefinesList
{
	my $codeRef 				= shift;
	$codeRef = FileGeneral::removeComments($codeRef);
	my @code = @$codeRef;

	my @includesList = ();
	foreach my $line (@code)
	{
		if ($line =~ m/^\#define/)
		{
			my (undef, $include) = split(/ /, $line);
			$include =~ s/^\s+//;
			$include =~ s/\s+$//;
			push (@includesList, $include);
		}
	}
	return \@includesList;
}

############################# Function Prototype Functions ##############################
sub getFunctionPrototypeList
{
	my $codeRef 				= shift;
	my $codeRef = getRawFunctionPrototypeLines($codeRef);
	my @code = @$codeRef;

	my @functionList = ();
	foreach my $line (@code)
	{
		my ($returnType, $function) = split(/ /, $line, 2);
		my ($function, $parms) = split (/\(/, $function);
		$function =~ s/^\s+//;
		$function =~ s/\s+$//;
		push (@functionList, $function);
	}
	return \@functionList;
}

sub getFunctionPrototypeReturnType
{
	my $codeRef 				= shift;
	my $function 				= shift;
	my $codeRef = getRawFunctionPrototypeLines($codeRef);
	my $returnType = "Error";
	my @code = @$codeRef;
	foreach my $line (@code)
	{
		my ($tmpReturnType, $tmpFunction) = split(/ /, $line, 2);
		my ($tmpFunction, $tmpParms) = split (/\(/, $tmpFunction);
		if ($tmpFunction eq $function)
		{
			$returnType = $tmpReturnType;
		}
	}
	return $returnType;
}

sub getFunctionPrototypeParms
{
	my $codeRef 				= shift;
	my $function 				= shift;
	$codeRef = getRawFunctionPrototypeLines($codeRef);
	my @parms = ("Error");
	my @code = @$codeRef;

	foreach my $line (@code)
	{
		my ($tmpReturnType, $tmpFunction) = split(/ /, $line, 2);
		my ($tmpFunction, $tmpParms) = split (/\(/, $tmpFunction);
		my ($tmpParms, undef) = split (/\)/, $tmpParms);
		if ($tmpFunction eq $function)
		{
			@parms = split(/,/, $tmpParms);
		}
	}
	foreach (@parms)
		{
		$_ =~ s/^\s+//;
		$_ =~ s/\s+$//;
		}
	return \@parms;
}

sub getRawFunctionPrototypeLines
{
	my $codeRef 				= shift;
	$codeRef = FileGeneral::concatLines($codeRef);
	my @code = @$codeRef;
	my @functionLine = ();
	foreach my $line (@code)
	{
		chomp($line);
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		foreach (functionReturnTypes())
		{
			if ($line =~ m/^$_/ && $line =~ m/\(/ && $line =~ m/\)/ && $line =~ m/;$/)
			{
				if ($line =~ m/=/) {}
				else
				{
					$line =~ s/^\s+//;
					$line =~ s/\s+$//;
					push (@functionLine, $line);
				}
			}
			if ($line =~ m/^$_/ && $line =~ m/\(/ && $line =~ m/,$/)
			{
				if ($line =~ m/=/) {}
				else
				{
					$line =~ s/^\s+//;
					$line =~ s/\s+$//;
					push (@functionLine, $line);
				}
			}
		}
	}
	return \@functionLine;
}

################################# Function Functions ####################################

sub getFunctionList
{
	my $codeRef 				= shift;
	my $codeRef = getRawFunctionLines($codeRef);
	my @code = @$codeRef;

	my @functionList = ();
	foreach my $line (@code)
	{
		my ($returnType, $function) = split(/ /, $line, 2);
		my ($function, $parms) = split (/\(/, $function);
		$function =~ s/^\s+//;
		$function =~ s/\s+$//;
		push (@functionList, $function);
	}
	return \@functionList;
}

sub getFunctionReturnType
{
	my $codeRef 				= shift;
	my $function 				= shift;
	my $codeRef = getRawFunctionLines($codeRef);
	my $returnType = "Error";
	my @code = @$codeRef;
	foreach my $line (@code)
	{
		my ($tmpReturnType, $tmpFunction) = split(/ /, $line, 2);
		my ($tmpFunction, $tmpParms) = split (/\(/, $tmpFunction);
		if ($tmpFunction eq $function)
		{
			$returnType = $tmpReturnType;
		}
	}
	return $returnType;
}

sub getFunctionParms
{
	my $codeRef 				= shift;
	my $function 				= shift;
	$codeRef = getRawFunctionLines($codeRef);
	my @parms = ("Error");
	my @code = @$codeRef;

	foreach my $line (@code)
	{
		my ($tmpReturnType, $tmpFunction) = split(/ /, $line, 2);
		my ($tmpFunction, $tmpParms) = split (/\(/, $tmpFunction);
		my ($tmpParms, undef) = split (/\)/, $tmpParms);
		if ($tmpFunction eq $function)
		{
			@parms = split(/,/, $tmpParms);
		}
	}
	foreach (@parms)
		{
		$_ =~ s/^\s+//;
		$_ =~ s/\s+$//;
		}
	return \@parms;
}


sub getRawFunctionLines
{
	my $codeRef 				= shift;
	$codeRef = FileGeneral::concatLines($codeRef);
	my @code = @$codeRef;
	my @functionLine = ();
	foreach my $line (@code)
	{
		chomp($line);
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		foreach (functionReturnTypes())
		{
		if ($line =~ m/^$_/ && $line =~ m/\(/ && $line =~ m/\)/ && ($line =~ m/\)$/ || $line =~ m/\{$/))
			{
				if ($line =~ m/=/) {}
				else
				{
					$line =~ s/^\s+//;
					$line =~ s/\s+$//;
					push (@functionLine, $line);
				}
			}
		}
	}
	return \@functionLine;
}

sub getFunctionCode
{
	my $codeRef 				= shift;
	my $function 				= shift;
	$codeRef = FileGeneral::concatLines($codeRef);

	my @functionCode = ();

	my $isInFunction = 0;
	my $braketCount = 0;
	my $hasHitBracket = 0;
	foreach my $line (@$codeRef)
	{
		my $functionHeaderLine = 0;
		my $rawLine = $line;
		chomp($line);
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		foreach (functionReturnTypes())
		{
			if ($line =~ m/^$_/ && $line =~ m/\(/ && ($line =~ m/\)$/ || $line =~ m/{$/))
			{
				my ($tmpReturnType, $tmpFunction) = split(/ /, $line, 2);
				my ($tmpFunction, $tmpParms) = split (/\(/, $tmpFunction);
				if ($tmpFunction eq $function)
				{
					$isInFunction = 1;
					$functionHeaderLine = 1;
				}
			}
		}
		if ($line =~ m/{/ && $isInFunction)
		{
		$braketCount++;
		$hasHitBracket = 1;
		}
		if ($line =~ m/}/ && $isInFunction) { $braketCount--; }
		if ($isInFunction == 1) { push (@functionCode, $rawLine); }
		if ($braketCount == 0 && $isInFunction == 1 && $functionHeaderLine == 0 && $hasHitBracket == 1)
		{
			$isInFunction = 0;
			last;
		}
	}
	return \@functionCode;
}

sub getFunctionLineNumbers
{
	my $codeRef 				= shift;
	my $function 				= shift;
	$codeRef = FileGeneral::concatLines($codeRef);

	my $isInFunction = 0;
	my $braketCount = 0;

	my $lineCount = 0;
	my $startLine = 0;
	my $endLine = 0;
	foreach my $line (@$codeRef)
	{
		$lineCount++;
		my $functionHeaderLine = 0;
		my $rawLine = $line;
		chomp($line);
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		foreach (functionReturnTypes())
		{
			if ($line =~ m/^$_/ && $line =~ m/\(/ && ($line =~ m/\)$/ || $line =~ m/{$/))
			{
				my ($tmpReturnType, $tmpFunction) = split(/ /, $line, 2);
				my ($tmpFunction, $tmpParms) = split (/\(/, $tmpFunction);
				if ($tmpFunction eq $function)
				{
					$isInFunction = 1;
					$functionHeaderLine = 1;
					$startLine = $lineCount;
				}
			}
		}
		if ($line =~ m/{/ && $isInFunction) { $braketCount++; }
		if ($line =~ m/}/ && $isInFunction) { $braketCount--; }
		if ($braketCount == 0 && $isInFunction == 1 && $functionHeaderLine == 0)
		{
			$isInFunction = 0;
			$endLine = $lineCount;
			last;
		}
	}
	return $startLine . "~". $endLine;
}

# These are key indicators to finding any function prototype and function information
sub functionReturnTypes
{
	return ("int", "double", "void", "long");
}

# These are key indicators to finding any function prototype and function information
sub conditionalKeyWords
{
	return ("if", "while", "until", "switch", "for");
}

1;
