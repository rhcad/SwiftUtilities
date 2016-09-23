//
//  Errno.swift
//  SwiftIO
//
//  Created by Jonathan Wight on 9/29/15.
//
//  Copyright © 2016, Jonathan Wight
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

public enum Errno: Int32 {
    case eperm = 1
    case enoent = 2
    case esrch = 3
    case eintr = 4
    case eio = 5
    case enxio = 6
    case e2BIG = 7
    case enoexec = 8
    case ebadf = 9
    case echild = 10
    case edeadlk = 11
    case enomem = 12
    case eacces = 13
    case efault = 14
    case enotblk = 15
    case ebusy = 16
    case eexist = 17
    case exdev = 18
    case enodev = 19
    case enotdir = 20
    case eisdir = 21
    case einval = 22
    case enfile = 23
    case emfile = 24
    case enotty = 25
    case etxtbsy = 26
    case efbig = 27
    case enospc = 28
    case espipe = 29
    case erofs = 30
    case emlink = 31
    case epipe = 32
    case edom = 33
    case erange = 34
    case eagain = 35
//    EWOULDBLOCK	EAGAIN		/* Operation would block */
    case einprogress = 36
    case ealready = 37
    case enotsock = 38
    case edestaddrreq = 39
    case emsgsize = 40
    case eprototype = 41
    case enoprotoopt = 42
    case eprotonosupport = 43
    case esocktnosupport = 44
    case enotsup = 45
    case epfnosupport = 46
    case eafnosupport = 47
    case eaddrinuse = 48
    case eaddrnotavail = 49
    case enetdown = 50
    case enetunreach = 51
    case enetreset = 52
    case econnaborted = 53
    case econnreset = 54
    case enobufs = 55
    case eisconn = 56
    case enotconn = 57
    case eshutdown = 58
    case etoomanyrefs = 59
    case etimedout = 60
    case econnrefused = 61
    case eloop = 62
    case enametoolong = 63
    case ehostdown = 64
    case ehostunreach = 65
    case enotempty = 66
    case eproclim = 67
    case eusers = 68
    case edquot = 69
    case estale = 70
    case eremote = 71
    case ebadrpc = 72
    case erpcmismatch = 73
    case eprogunavail = 74
    case eprogmismatch = 75
    case eprocunavail = 76
    case enolck = 77
    case enosys = 78
    case eftype = 79
    case eauth = 80
    case eneedauth = 81
    case epwroff = 82
    case edeverr = 83
    case eoverflow = 84
    case ebadexec = 85
    case ebadarch = 86
    case eshlibvers = 87
    case ebadmacho = 88
    case ecanceled = 89
    case eidrm = 90
    case enomsg = 91
    case eilseq = 92
    case enoattr = 93
    case ebadmsg = 94
    case emultihop = 95
    case enodata = 96
    case enolink = 97
    case enosr = 98
    case enostr = 99
    case eproto = 100
    case etime = 101
    case eopnotsupp = 102
    case enopolicy = 103
    case enotrecoverable = 104
    case eownerdead = 105
    case eqfull = 106
}

extension Errno: Swift.Error {
}
