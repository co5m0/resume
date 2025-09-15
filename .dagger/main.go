// A generated module for Resume functions
//
// This module has been generated via dagger init and serves as a reference to
// basic module structure as you get started with Dagger.
//
// Two functions have been pre-created. You can modify, delete, or add to them,
// as needed. They demonstrate usage of arguments and return types using simple
// echo and grep commands. The functions can be called from the dagger CLI or
// from one of the SDKs.
//
// The first line in this comment block is a short description line and the
// rest is a long description with more detail on the module's purpose or usage,
// if appropriate. All modules should have a short description.

package main

import (
	"context"
	"dagger/resume/internal/dagger"
)

type Resume struct{}

// Returns a container that echoes whatever string argument is provided
func (m *Resume) ContainerEcho(stringArg string) *dagger.Container {
	return dag.Container().From("alpine:latest").WithExec([]string{"echo", stringArg})
}

// Returns lines that match a pattern in the files of the provided Directory
func (m *Resume) GrepDir(ctx context.Context, directoryArg *dagger.Directory, pattern string) (string, error) {
	return dag.Container().
		From("alpine:latest").
		WithMountedDirectory("/mnt", directoryArg).
		WithWorkdir("/mnt").
		WithExec([]string{"grep", "-R", pattern, "."}).
		Stdout(ctx)
}

func (m *Resume) Build(ctx context.Context, source *dagger.Directory) *dagger.File {
	// nixCache := dag.CacheVolume("nix")
	// homeCache := dag.CacheVolume("home")

	return dag.Nix().SetupNix().
		// WithMountedCache("/nix", nixCache).
		// WithMountedCache("/root", homeCache).
		WithMountedDirectory("/src", source).
		WithWorkdir("/src").
		WithExec([]string{"nix", "develop", "-c", "./generate.sh"}).
		File("/src/resume.pdf")
}

func (m *Resume) Save(ctx context.Context, source *dagger.Directory) (string, error) {
	return m.Build(ctx, source).Name(ctx)
}
