<?php

class SystemBridge
{
	static function SendCommand($command, array $args)
	{
		$escapedCommand = escapeshellcmd($command);
		$escapedArguments = self::escapeArguments($args);
		
		$combinedArguments = null;
		foreach ($escapedArguments as $escapedArg)
		{
			$combinedArguments .= " " . $escapedArg;
		}
		
		$command = $escapedCommand . $combinedArguments;
		
		system($command, $returnedSystemInfo);
		
		return $returnedSystemInfo;
	}
	
	static private function escapeArguments(array $args)
	{
		$escapedArguments = array();
		
		foreach ($args as $arg)
		{
			$escapedArguments[] = escapeshellarg($arg);
		}
		
		return $escapedArguments;
	}
}

?>