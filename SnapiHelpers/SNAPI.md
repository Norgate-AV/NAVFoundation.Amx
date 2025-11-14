# SNAPI

## Commands

Commands in **SNAPI** are used for discrete and momentary functions when the function requires textual information, multiple parameters, or the functions are not commonly used. For instance, Temperature scale is set via a command because this is usually done only once in a control system program.

Other functions, such as adding and removing lighting and keypad addresses, requires more information than a channel or level alone can convey. All commands start with a command header, followed by a `-` to separate the command from the data, and data arguments are usually separated by `,`'s.

Commands used to query for the status of a property start with a `?`. Query commands cause the module to respond with a response command.

Commands in **SNAPI** are sent like commands to other devices, using the `SEND_COMMAND` keyword:

```netlinx-source
SEND_COMMAND dvDevice, '?VERSION'
```

Commands used to query for the status of a property start with a `?`. Query commands cause the module to respond with a response command. Note that this
response is a command, not a string and can be captured in a `DATA_EVENT` in the `COMMAND` sub-section:

```netlinx-source
DATA_EVENT[dvDevice]
{
    COMMAND:
    {
        // DATA.TEXT holds the response to a query command
    }
}
```

## Commands and Escape Characters

**SNAPI** command uses comma as a parameter separator. If a parameter's value contains a comma, the parameter is escaping using double quotes at the start and end
of the parameter. If a parameter's value contains a double quote character it is escaped with a pair of double quote characters.

The following examples are properly escaped parameter values:

- `6`
- `Hello`
- `Brown Eyed Girl`
- `"Morrison, Van"`
- `"Van ""The Man"" Morrison"`

The following examples are improperly escaped parameter values:

- `Morrison, Van`
- `Van "The Man" Morrison`

`SNAPI.axi` includes a few helpful routines to build commands:

- `DuetPackCmdHeader(Hdr)`
- `DuetPackCmdParam(Cmd, Param)`
- `DuetPackCmdParamArray(Cmd, Params[])`

`DuetPackCmdHeader` is a command using a given command header where `Hdr` is the command header. `DuetPackCmdParam` adds a parameter to the command, escaping the parameter and adding parameter separators as needed; `Cmd` is the command to which the parameter is added and `Param` is the parameter to be added.

`DuetPackCmdParamArray` is similar to `DuetPackCmdParam` but it takes an array of parameters and adds them to the command. All of these functions return the updated command.

`SNAPI.axi` includes a few helpful routines to parse commands as well:

- `DuetParseCmdHeader(Cmd)`
- `DuetParseCmdParam(Cmd)`

`DuetParseCmdHeader` removes and returns the command header from a command. `DuetParseCmdParam` removes and returns the next parameter from the command, un-escaping the parameter as needed. Both of these functions return a string containing the command header or the parameter.

An example program using these routines is shown below:

```netlinx-source
// Build a command to be stored in cTestCmd
cTestCmd = DuetPackCmdHeader('COMMAND')
cTestCmd = DuetPackCmdParam(cTestCmd, 'Morrison,Van')
cTestCmd = DuetPackCmdParam(cTestCmd, 'Wild Nights')
cTestCmd = DuetPackCmdParam(cTestCmd, '"The Man"')
cTestCmd = DuetPackCmdParam(cTestCmd, 'Tupelo Honey')

// Resulting command is:
// 'COMMAND-"Morrison, Van",Wild Nights,""The Man"",Tupelo Honey'

// Remove the parameters for this command
cCmdheader = DuetParseCmdHeader(cTestCmd)
SWITCH (cCmdheader)
{
    CASE 'COMMAND':
    {
        cParam1 = DuetParseCmdParam(cTestCmd)
        cParam2 = DuetParseCmdParam(cTestCmd)
        cParam3 = DuetParseCmdParam(cTestCmd)
        cParam4 = DuetParseCmdParam(cTestCmd)

        // cParam1 = 'Morrison, Van'
        // cParam2 = 'Wild Nights'
        // cParam3 = '"The Man"'
        // cParam4 = 'Tupelo Honey'
    }
}
```

## Duet Functions from `SNAPI.axi`

```netlinx-source
// Name   : ==== DuetPackCmdHeader ====
// Purpose: To package header for module send_command or send_string
// Params : (1) IN - sndcmd/str header
// Returns: Packed header with command separator added if missing
// Notes  : Adds the command header to the string and adds the command if missing
//          This function assumes the standard Duet command separator '-'
//
DEFINE_FUNCTION CHAR[DUET_MAX_HDR_LEN] DuetPackCmdHeader(CHAR cHdr[])
{
  STACK_VAR CHAR cSep[1]
  cSep = '-'

  IF (RIGHT_STRING(cHdr,LENGTH_STRING(cSep)) != cSep)
      RETURN "cHdr,cSep";

  RETURN cHdr;
}

// Name   : ==== DuetPackCmdParam ====
// Purpose: To package parameter for module send_command or send_string
// Params : (1) IN - sndcmd/str to which parameter will be added
//          (2) IN - sndcmd/str parameter
// Returns: Packed parameter wrapped in double-quotes if needed, added to the command
// Notes  : Wraps the parameter in double-quotes if it contains the separator
//          This function assumes the standard Duet parameter separator ','
//
DEFINE_FUNCTION CHAR[DUET_MAX_CMD_LEN] DuetPackCmdParam(CHAR cCmd[], CHAR cParam[])
{
  STACK_VAR CHAR cTemp[DUET_MAX_CMD_LEN]
  STACK_VAR CHAR cTempParam[DUET_MAX_CMD_LEN]
  STACK_VAR CHAR cCmdSep[1]
  STACK_VAR CHAR cParamSep[1]
  STACK_VAR INTEGER nLoop
  cCmdSep = '-'
  cParamSep = ','

  // Not the first param?  Add the param separator
  cTemp = cCmd
  IF (FIND_STRING(cCmd,cCmdSep,1) != (LENGTH_STRING(cCmd)-LENGTH_STRING(cCmdSep)+1))
    cTemp = "cTemp,cParamSep"

  // Escape any quotes
  FOR (nLoop = 1; nLoop <= LENGTH_ARRAY(cParam); nLoop++)
  {
    IF (cParam[nLoop] == '"')
      cTempParam = "cTempParam,'"'"
    cTempParam = "cTempParam,cParam[nLoop]"
  }

  // Add the param, wrapped in double-quotes if needed
  IF (FIND_STRING(cTempParam,cParamSep,1) > 0)
      cTemp = "cTemp,'"',cTempParam,'"'"
  ELSE
      cTemp = "cTemp,cTempParam"

  RETURN cTemp;
}

// Name   : ==== DuetPackCmdParamArray ====
// Purpose: To package parameters for module send_command or send_string
// Params : (1) IN - sndcmd/str to which parameter will be added
//          (2) IN - sndcmd/str parameter array
// Returns: packed parameters wrapped in double-quotes if needed
// Notes  : Wraps the parameter in double-quotes if it contains the separator
//          and separates them using the separator sequence
//          This function assumes the standard Duet parameter separator ','
//
DEFINE_FUNCTION CHAR[DUET_MAX_CMD_LEN] DuetPackCmdParamArray(CHAR cCmd[], CHAR cParams[][])
{
  STACK_VAR CHAR    cTemp[DUET_MAX_CMD_LEN]
  STACK_VAR INTEGER nLoop
  STACK_VAR INTEGER nMax
  STACK_VAR CHAR cCmdSep[1]
  STACK_VAR CHAR cParamSep[1]
  cCmdSep = '-'
  cParamSep = ','

  nMax = LENGTH_ARRAY(cParams)
  IF (nMax == 0)
    nMax = MAX_LENGTH_ARRAY(cParams)

  cTemp = cCmd
  FOR (nLoop = 1; nLoop <= nMax; nLoop++)
    cTemp = DuetPackCmdParam(cTemp,cParams[nLoop])

  RETURN cTemp;
}

// Name   : ==== DuetPackCmdSimple ====
// Purpose: To package header and 1 parameter for module send_command or send_string
// Params : (1) IN - sndcmd/str header
//          (2) IN - sndcmd/str parameter
// Returns: Packed header with command separator added if missing and parameter
// Notes  : Adds the command header to the string and adds the command if missing
//          This function assumes the standard Duet command separator '-'
//          This function also adds a parameter to the command
//
DEFINE_FUNCTION CHAR[DUET_MAX_CMD_LEN] DuetPackCmdSimple(CHAR cHdr[], CHAR cParam[])
{
  STACK_VAR CHAR cCmd[DUET_MAX_CMD_LEN]

  cCmd = DuetPackCmdHeader(cHdr)
  cCmd = DuetPackCmdParam(cCmd,cParam)
  RETURN cCmd;
}

// Name   : ==== DuetParseCmdHeader ====
// Purpose: To parse out parameters from module send_command or send_string
// Params : (1) IN/OUT  - sndcmd/str data
// Returns: parsed property/method name, still includes the leading '?' if present
// Notes  : Parses the strings sent to or from modules extracting the command header.
//          Command separating character assumed to be '-', Duet standard
//
DEFINE_FUNCTION CHAR[DUET_MAX_HDR_LEN] DuetParseCmdHeader(CHAR cCmd[])
{
  STACK_VAR CHAR cTemp[DUET_MAX_HDR_LEN]
  STACK_VAR CHAR cSep[1]
  cSep = '-'

  // Assume the argument to be the command
  cTemp = cCmd

  // If we find the seperator, remove it from the command
  IF (FIND_STRING(cCmd,cSep,1) > 0)
  {
    cTemp = REMOVE_STRING(cCmd,cSep,1)
    IF (LENGTH_STRING(cTemp))
      cTemp = LEFT_STRING(cTemp,LENGTH_STRING(cTemp)-LENGTH_STRING(cSep))
  }

  // Did not find seperator, argument is the command (like ?SOMETHING)
  ELSE
    cCmd = ""

  RETURN cTemp;
}

// Name   : ==== DuetParseCmdParam ====
// Purpose: To parse out parameters from module send_command or send_string
// Params : (1) IN/OUT  - sndcmd/str data
// Returns: Parse parameter from the front of the string not including the separator
// Notes  : Parses the strings sent to or from modules extracting the parameters.
//          A single param is picked of the cmd string and removed, through the separator.
//          The separator is NOT returned from the function.
//          If the first character of the param is a double quote, the function will
//          remove up to (and including) the next double-quote and the separator without spaces.
//          The double quotes will then be stripped from the parameter before it is returned.
//          If the double-quote/separator sequence is not found, the function will remove up to (and including)
//          the separator character and the leading double quote will NOT be removed.
//          If the separator is not found, the entire remained of the command is removed.
//          Command separating character assumed to be ',', Duet standard
//
DEFINE_FUNCTION CHAR[DUET_MAX_PARAM_LEN] DuetParseCmdParam(CHAR cCmd[])
{
  STACK_VAR CHAR cTemp[DUET_MAX_PARAM_LEN]
  STACK_VAR CHAR cSep[1]
  STACK_VAR CHAR chC
  STACK_VAR INTEGER nLoop
  STACK_VAR INTEGER nState
  STACK_VAR CHAR bInquotes
  STACK_VAR CHAR bDone
  cSep = ','

  // Reset state
  nState = 1; //ST_START
  bInquotes = FALSE;
  bDone = FALSE;

  // Loop the command and escape it
  FOR (nLoop = 1; nLoop <= LENGTH_ARRAY(cCmd); nLoop++)
  {
    // Grab characters and process it based on state machine
    chC = cCmd[nLoop];
    Switch (nState)
    {
      // Start or string: end of string bails us out
      CASE 1: //ST_START
      {
        // Starts with a quote?
        // If so, skip it, set flag and move to collect.
        IF (chC == '"')
        {
          nState = 2; //ST_COLLECT
          bInquotes = TRUE;
        }

        // Starts with a comma?  Empty param
        ELSE IF (chC == ',')
        {
          // I am done
          bDone = TRUE;
        }

        // Not a quote or a comma?  Add it to the string and move to collection
        Else
        {
          cTemp = "cTemp, chC"
          nState = 2; //ST_COLLECT
        }
        BREAK;
      }

      // Collect string.
      CASE 2: //ST_COLLECT
      {
        // If in quotes, just grab the characters
        IF (bInquotes)
        {
          // Ah...found a quote, jump to end quote state
          IF (chC == '"' )
          {
            nState = 3; //ST_END_QUOTE
            BREAK;
          }
        }

        // Not in quotes, look for commas
        ELSE IF (chC == ',')
        {
          // I am done
          bDone = TRUE;
          BREAK;
        }

        // Not in quotes, look for quotes (this would be wrong)
        // But instead of barfing, I will just add the quote (below)
        ELSE IF (chC == '"' )
        {
          // I will check to see if it should be escaped
          IF (nLoop < LENGTH_ARRAY(cCmd))
          {
            // If this is 2 uqotes back to back, just include the one
            IF (cCmd[nLoop+1] = '"')
              nLoop++;
          }
        }

        // Add character to collection
        cTemp = "cTemp,chC"
        BREAK;
      }

      // End Quote
      CASE 3: //ST_END_QUOTE
      {
        // Hit a comma
        IF (chC == ',')
        {
          // I am done
          bDone = TRUE;
        }

        // OK, found a quote right after another quote.  So this is escaped.
        ELSE IF (chC == '"')
        {
          cTemp = "cTemp,chC"
          nState = 2; //ST_COLLECT
        }
        BREAK;
      }
    }

    // OK, if end of string or done, process and exit
    IF (bDone == TRUE || nLoop >= LENGTH_ARRAY(cCmd))
    {
      // remove cTemp from cCmd
      cCmd = MID_STRING(cCmd, nLoop + 1, LENGTH_STRING(cCmd) - nLoop)

      // cTemp is done
      RETURN cTemp;
    }
  }

  // Well...we should never hit this
  RETURN "";
}
```
