/*
 * PineFile.cpp
 *
 *  Created on: May 19, 2011
 *      Author: lxb
 */

namespace Pine 
{

File::File()
{

}

File::File(String& path)
{
}

File::~File()
{

}

bool File::exists()
{
    return true;
}

bool File::isFile()
{
    return true;
}

bool File::isDirectory()
{
    return false;
}

void File::delete()
{
}

void File::chmod(uint access)
{
}

String File::getAbsolutePath()
{

}

}
