configuration InstallBaseline {

    Import-DscResource nx
    node Linux.Baseline {
        nxPackage nano {
            Name = 'nano'
        }
        nxPackage httpd {
            Name = 'httpd'
        }
    }
}