function homeDir = getEnvHome()
    if ismac
        homeDir = getenv('HOME');
    end
    if ispc
        homeDir = getenv('HOMEPATH');
    end
end
