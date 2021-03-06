$WRK_DIR="C:\GitRepo3D\DemoTest\001"
$INS_DIR="C:\Program Files\WhereScape\WhereScape 3D"
$EXE_DIR="C:\Program Files\WhereScape\RED"

$REPO_3D="DemoRepo"
$CATG_3D="RED export"
$MOD_NAM="wsDVDemo"
$MOD_VER="20210716"

$RED_MET="WhereScape"
$RED_ARC=64
$RED_USR="Demo"


$FIL_NAM= -join( $MOD_NAM,$MOD_VER)
$JAVA_EX= -join( $INS_DIR,"\jre\bin\java.exe")
$JAR_FIL= -join( $INS_DIR,"\WhereScape-3D-HEAD-bundle.jar")
$RED_CLI= -join( $EXE_DIR,"\redcli.exe")
$XML_FIL= -join( $WRK_DIR,"\",$FIL_NAM,".xml")
$DDL_FIL= -join( $WRK_DIR,"\",$FIL_NAM,".ddl")
$LOG_FIL= -join( $WRK_DIR,"\",$FIL_NAM,".log")

$RESULT_MSG = ""


$PS_STEP = 100 
$PS_Description = "Checks if the files exist and deletes if they do"


if (-not (Test-Path -LiteralPath $XML_FIL)) {
    
    TRY {
        Remove-Item -Recurse -Force "$XML_FIL" -ErrorAction Ignore
        $RESULT_MSG = -join($RESULT_MSG,"Successfully deleted '$XML_FIL'.`n")
    }
    CATCH {
        Write-Error -Message "Unable to delete '$XML_FIL'. Error was: $_" -ErrorAction Stop
    }
} 

if (-not (Test-Path -LiteralPath $DDL_FIL)) {
    
    TRY {
        Remove-Item -Recurse -Force "$DDL_FIL" -ErrorAction Ignore
        $RESULT_MSG = -join($RESULT_MSG,"Successfully deleted '$DDL_FIL'.`n")
    }
    CATCH {
        Write-Error -Message "Unable to delete '$DDL_FIL'. Error was: $_" -ErrorAction Stop
    }
} 

if (-not (Test-Path -LiteralPath $LOG_FIL)) {
    
    TRY {
        Remove-Item -Recurse -Force "$LOG_FIL" -ErrorAction Ignore
        $RESULT_MSG = -join($RESULT_MSG,"Successfully deleted '$LOG_FIL'.`n")
    }
    CATCH {
        Write-Error -Message "Unable to delete '$LOG_FIL'. Error was: $_" -ErrorAction Stop
    }
} 

$PS_STEP = 200 
$PS_Description = "Export model"

TRY {
    #Start-Process "$JAVA_EX" -Xmx512m -XX:MaxMetaspaceSize=256m -splash: -jar "C:\Program Files\WhereScape\WhereScape 3D\WhereScape-3D-HEAD-bundle.jar" redexport -r $REPO_3D -c $CATG_3D -m $MOD_NAM -v $MOD_VER -o $XML_FIL > $LOG_FIL 2>&1
    $output = & "$JAVA_EX" -Xmx512m -XX:MaxMetaspaceSize=256m -splash: -jar $JAR_FIL redexport -r $REPO_3D -c $CATG_3D -m $MOD_NAM -v $MOD_VER -o $XML_FIL -f > $LOG_FIL 2>&1
    $RESULT_MSG = -join($RESULT_MSG,"Application $MOD_VER $MOD_NUM created for $REPO_3D`n")
    $RESULT_MSG = -join($RESULT_MSG,"$output`n") 
    $output = Get-Content $AppLogFile -Raw 
    $RESULT_MSG = -join($RESULT_MSG,"Generated Application for $DocFolder`n")
    $RESULT_MSG = -join($RESULT_MSG,"$output`n")
    $PS_STATUS = 1
}

 

CATCH {
    #$RESULT_MSG = -join($RESULT_MSG,"Error! $output`n")
    #$PS_STATUS = -2
}


$PS_STEP = 400 
$PS_Description = "Deploy the Wherescapre Red application"
TRY {
    
    $output = & "$RED_CLI" deployment deploy --xml-file-name $XML_FIL --meta-dsn $RED_MET --meta-dsn-arch $RED_ARC --red-user-name $RED_USR --ddl-file-name $DDL_FIL >> $LOG_FIL 2>&1
    
	
	$RESULT_MSG = -join($RESULT_MSG,"Application $MOD_VER $MOD_NUM Released to $REPO_3D`n")
    $RESULT_MSG = -join($RESULT_MSG,"$output`n")
    #Reads Log File and addes to output
    $output = Get-Content $AppLogFile -Raw
    $RESULT_MSG = -join($RESULT_MSG,"$output`n")
    $PS_STATUS = 1
}

CATCH {
    $RESULT_MSG = -join($RESULT_MSG,"Step: $PS_STEP`n","Step Message: $PS_Description`n","Error! $output`n")
    $PS_STATUS = -2
}

Write-Output $PS_STATUS;  
Write-Output $RESULT_MSG; 
Write-Output $PS_Description;
                       
                       if ($PS_STATUS = 1) 
                       {
                          $LASTEXITCODE = 0
                       }
                       EXIT $LastExitCode