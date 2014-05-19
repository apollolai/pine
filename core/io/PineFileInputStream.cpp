/*
 * PineFileStream.cpp
 *
 *  Created on: May 19, 2011
 *      Author: lxb
 */

#include <PineFileStream.h>

namespace Pine 
{

FileStream::FileStream()
{

}

FileStream::FileStream(String& filePath)
{
}

FileStream::~FileStream()
{
}

uchar FileStream::readByte()
{
    uchar buf[1];

    buf[0] = 0;
    fread(buf, 1, 1, m_pFile)
    return buf[0];
}

int FileStream::read(void* buf, size_t count)
{
    return fread(buf, 1, count, m_pFile);
}

void FileStream::skip(uint64 count)
{
    fseek(m_pFile, count, SEEK_CUR);
}

int FileStream::available()
{
    return 0;
}

void FileStream::finalize()
{
    
}

void FileStream::close()
{
}

}
