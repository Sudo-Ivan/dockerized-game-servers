package game

import "io"

type Backup interface {
	FilenamePrefix() string
	WriteArchive(w io.Writer) error
	RestoreArchive(r io.ReaderAt, size int64) error
}
