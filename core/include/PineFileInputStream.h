/*
 * PineFileStream.h
 *
 *  Created on: May 19, 2014
 *      Author: lxb
 */

#ifndef _PineFileStream_H_
#define _PineFileStream_H_

namespace Pine {

class FileStream
{
public:
    FileStream();
    FileStream(String& path);
    ~FileStream();
    uchar readByte();
    int read(void* buf, size_t count);
    void skip(uint64 count);
    int available();
    void finalize();
    void close();

private:
    File *m_pFile;
};

}

#endif /* _PineFileStream_H_ */


