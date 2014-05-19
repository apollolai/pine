/*
 * PineFile.h
 *
 *  Created on: May 19, 2014
 *      Author: lxb
 */

#ifndef _PineFile_H_
#define _PineFile_H_

namespace Pine
{
class File
{
public:
    File();
    File(String& path);
    ~File();
    bool exists();
    bool isFile();
    bool isDirectory();
    void delete();
    void chmod(uint access);
    String getAbsolutePath();

private:
    String m_path;
};
}
#endif /* _PineFile_H_ */

