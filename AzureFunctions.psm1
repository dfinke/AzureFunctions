class TemplateKey {
    $Id
    $Language

    TemplateKey($Id, $Language) {
        $this.Id = $Id    
        $this.Language = $Language    
    }
}

function InvokeLoadTemplates {
    if ($script:templates -eq $null) {
        $urlLatestTemplates = 'https://functions.azure.com/api/templates?runtime=latest'
        $script:templates = Invoke-RestMethod $urlLatestTemplates
    }
}

function Get-Template {
    [OutputType([TemplateKey])]
    param(
        $Id,
        $Language
    )

    InvokeLoadTemplates
    
    $targetTemplates = $script:templates | 
        ForEach-Object {
        [TemplateKey]::new($_.id, $_.metadata.language)
    } 
    
    if (!$Language) {$Language = '*'}
    if (!$Id) {$Id = '*'}

    $targetTemplates | 
        Where-Object {
        $_.Language -like $Language -and 
        $_.Id -like $Id
    } | Sort-Object language
}

function Export-Template {
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        $TemplateId
    )

    Process {    
        
        $template = $script:templates | Where-Object { $_.Id -eq $TemplateId }

        $fn = $template.metadata.defaultFunctionName
        $targetPath = "$pwd\$fn"
        
        $null = mkdir $targetPath -ErrorAction Ignore        

        $template.function.bindings | 
            ConvertTo-Json | 
            Set-Content -Encoding Ascii "$($targetPath)\function.json"

        $template.files |
            Get-Member -MemberType NoteProperty | 
            ForEach-Object name |
            ForEach-Object {
            $template.files.$_ | Set-Content -Encoding Ascii "$($targetPath)\$($_)"
        }        
    }
}