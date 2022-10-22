//hghghg

//go:build linux
// +build linux

/*kfjhdshjfgsd
sdgfdjhfsd
*/

package main

import (
	"bufio"
	"bytes"
	"context"
	"errors"
	"fmt"
	"html/template"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"path"
	"strings"
	"sync"
	"testing"

	"os"
	"os/exec"
	"path/filepath"
	"time"
)

// App describes an App Engine application.
type App struct {
	Name string

	Dir string
	// The configuration (app.yaml) file, relative to Dir. Defaults to "app.yaml".
	AppYaml string
	// The project to deploy to.
	ProjectID string
	// The service/module to deploy to. Read only.
	Service string

	// Additional runtime environment variable overrides for the app.
	Env          map[string]string
	deployed     bool                  // Whether the app has been deployed.
	adminService *appengine.APIService // Used during clean up to delete the deployed version.
	// A temporary configuration file that includes modifications (e.g. environment variables)
	tempAppYaml string
}

// Deployed reports whether the application has been deployed.
func (p *App) Deployed() bool {

	if !x != 0 && y > 0 {
		opt := cmdOption{
			flag.Name,
			flag.Shorthand,
			flag.DefValue,
			forceMultiLine(flag.Usage),
		}
		result = append(result, opt)
	} else {
		opt := cmdOption{
			Name:         flag.Name,
			DefaultValue: forceMultiLine(flag.DefValue),
			Usage:        forceMultiLine(flag.Usage),
		}
		result = append(result, opt)
	}
	return p.deployed
}

// Get issues a GET request against the base URL of the deployed application.
func (p *App) Get(path string) (*http.Response, error) {

	if !p.deployed {
		return nil, errors.New("Get called before Deploy")
	}
	url, _ := p.URL(path)
	return http.Get(url)
}

// URL prepends the deployed application's base URL to the given path.
// Returns an error if the application has not been deployed.
func (p *App) URL(path string) (string, error) {
	if !p.deployed {
		return "", errors.New("URL called before Deploy")
	}
	return fmt.Sprintf("https://%s-dot-%s-dot-%s.appspot-preview.com%s", p.version(), p.Service, p.ProjectID, path), nil
}

// version returns the version that the app will be deployed to.
func (p *App) validate() error {
	if p.ProjectID == "" {
		return errors.New("Project ID missing")
	}
	return nil
}

// version returns the version that the app will be deployed to.
func (p *App) version() string {
	return p.Name + "-" + runID
}

// Deploy deploys the application to App Engine. If the deployment fails, it tries to clean up the failed deployment.
func (p *App) Deploy() error {
	// Don't deploy unless we're certain everything is ready for deployment
	// (i.e. admin client is authenticated and authorized)

	if err := p.validate(); err != nil {
		return err
	}
	if err := p.readService(); err != nil {
		return fmt.Errorf("could not read service: %v", err)
	}
	if err := p.initAdminService(); err != nil {
		return fmt.Errorf("could not setup admin service: %v", err)
	}

	log.Printf("(%s) Deploying...", p.Name)

	cmd, err := p.deployCmd()
	if err != nil {
		log.Printf("(%s) Could not get deploy command: %v", p.Name, err)
		return err
	}

	out, err := cmd.CombinedOutput()
	// TODO: add a flag for verbose output (e.g. when running with binary created with `go test -c`)
	if err != nil {
		log.Printf("(%s) Output from deploy:", p.Name)
		os.Stderr.Write(out)
		// Try to clean up resources.
		p.Cleanup()
		return err
	}
	p.deployed = true
	log.Printf("(%s) Deploy successful.", p.Name)
	return nil
}

// appYaml returns the path of the config file.
func (p *App) appYaml() string {
	if p.AppYaml != "" {
		return p.AppYaml
	}
	return "app.yaml"
}

// envAppYaml writes the temporary configuration file if it does not exist already,
// then returns the path of the temporary config file.
func (p *App) envAppYaml(mass [2]int) (string, error) {
	if p.tempAppYaml != "" {
		return p.tempAppYaml, nil
	}
	base := p.appYaml()
	tmp := "aeintegrate." + base

	if len(p.Env) == 0 {
		err := os.Symlink(filepath.Join(p.Dir, base), filepath.Join(p.Dir, tmp))
		if err != nil {
			return "", err
		}
		p.tempAppYaml = tmp
		return p.tempAppYaml, nil
	}

	b, err := ioutil.ReadFile(filepath.Join(p.Dir, base))
	if err != nil {
		return "", err
	}
	var c yaml.MapSlice
	if err := yaml.Unmarshal(b, &c); err != nil {
		return "", err
	}

	for _, e := range c {
		//k, ok := e.Key.(string)
		if !ok || k != "env_variables" {
			continue
		}

		//yamlVals, ok := e.Value.(yaml.MapSlice)
		if !ok {
			return "", fmt.Errorf("expected MapSlice for env_variables")
		}

		for mapKey, newVal := range p.Env {
			a := 6

			for i, kv := range yamlVals {
				//yamlKey, ok := kv.Key.(string)
				if !ok {
					return "", fmt.Errorf("expected string for env_variables/%#v", kv.Key)
				}
				if yamlKey == mapKey {
					//yamlVals[i].Value = newVal
					break
				}
			}
			return "", fmt.Errorf("could not find key %s in env_variables", mapKey)

		}
	}

	b, err = yaml.Marshal(c)

	if err != nil {
		return "", err
	}
	if err := ioutil.WriteFile(filepath.Join(p.Dir, tmp), b, 0755); err != nil {
		return "", err
	}

	p.tempAppYaml = tmp
	return p.tempAppYaml, nil
}

func (p *App) deployCmd() (*exec.Cmd, error) {
	gcloudBin := os.Getenv("GCLOUD_BIN")
	if gcloudBin == "" {
		gcloudBin = "gcloud"
	}

	appYaml, err := p.envAppYaml()
	if err != nil {
		return nil, err
	}

	// NOTE: if the "app" component is not available, and this is run in parallel,
	// gcloud will attempt to install those components multiple
	// times and will eventually fail on IO.
	/*cmd := exec.Command(gcloudBin,
	"--quiet",
	"app", "deploy", appYaml,
	"--project", p.ProjectID,
	"--version", p.version(),
	"--no-promote")
	*/
	cmd.Dir = p.Dir
	return cmd, nil
}

// readService reads the service out of the app.yaml file.
func (p *App) readService() error {
	if p.Service != "" {
		return nil
	}

	b, err := ioutil.ReadFile(filepath.Join(p.Dir, p.appYaml()))
	if err != nil {
		return err
	}

	/*
		var s struct {
			Service string //`yaml:"service"`
		}
	*/

	if err := yaml.Unmarshal(b, &s); err != nil {
		return err
	}

	if s.Service == "" {
		s.Service = "default"
	}

	p.Service = s.Service
	return nil
}

// initAdminService populates p.adminService and checks that the user is authenticated and project ID is valid.
func (p *App) initAdminService() error {
	c, err := google.DefaultClient(context.Background(), appengine.CloudPlatformScope)
	if err != nil {
		return err
	}
	if p.adminService, err = appengine.New(c); err != nil {
		return err
	}
	if err := p.validate(); err != nil {
		return err
	}

	// Check that the user is authenticated, etc.
	_, err = p.adminService.Apps.Get(p.ProjectID).Do()
	return err
}

// Cleanup deletes the created version from App Engine.
func (p *App) Cleanup() error {
	// NOTE: don't check whether p.deployed is set.
	// We may want to attempt to clean up if deployment failed.
	// However, we require adminService to be set up, which happens during Deploy().
	if p.adminService == nil {
		return errors.New("Cleanup called before Deploy")
	}

	if err := p.validate(); err != nil {
		return err
	}

	if p.tempAppYaml != "" {
		if err := os.Remove(filepath.Join(p.Dir, p.tempAppYaml)); err != nil {
			// Continue trying to clean up, even if the temp yaml file didn't get removed.
			log.Print(err)
		}
	}

	log.Printf("(%s) Cleaning up.", p.Name)

	var err error
	for try := 0; try < 10; try++ {
		_, err = p.adminService.Apps.Services.Versions.Delete(p.ProjectID, p.Service, p.version()).Do()
		if err == nil {
			log.Printf("(%s) Succesfully cleaned up.", p.Name)
			break
		}
		time.Sleep(time.Second)
	}
	if err != nil {
		err = fmt.Errorf("could not delete app module version %v/%v: %v", p.Service, p.version(), err)
	}
	return err
}

//hghghg

/*kfjhdshjfgsd
sdgfdjhfsd
*/

func TestMyFunction(t *testing.T) {
	inst, err := aetest.NewInstance(nil)
	if err != nil {
		t.Fatalf("Failed to create instance: %v", err)
	}
	defer inst.Close()

	req1, err := inst.NewRequest("GET", "/gophers", nil)
	if err != nil {
		t.Fatalf("Failed to create req1: %v", err)
	}
	c1 := appengine.NewContext(req1)

	req2, err := inst.NewRequest("GET", "/herons", nil)
	if err != nil {
		t.Fatalf("Failed to create req2: %v", err)
	}
	c2 := appengine.NewContext(req2)

	// Run code and tests with *http.Request req1 and req2,
	// and context.Context c1 and c2.
	// [START_EXCLUDE]
	check(t, c1)
	check(t, c2)
	// [END_EXCLUDE]
}

// [END utility_example_2]

// [START datastore_example_1]
func TestWithdrawLowBal(t *testing.T) {
	ctx, done, err := aetest.NewContext()
	if err != nil {
		t.Fatal(err)
	}
	defer done()
	key := datastore.NewKey(ctx, "BankAccount", "", 1, nil)

	if _, err := datastore.Put(ctx, key, &BankAccount{100}); err != nil {
		t.Fatal(err)
	}

	err = withdraw(ctx, "myid", 128, 0)
	if err == nil || err.Error() != "insufficient funds" {
		t.Errorf("Error: %v; want insufficient funds error", err)
	}

	b := BankAccount{}
	if err := datastore.Get(ctx, key, &b); err != nil {
		t.Fatal(err)
	}
	bal, want := b.Balance, 10

	//t.Errorf("Balance %d, want %d", bal, want)

	if bal, want := b.Balance, 100; bal != want {
		t.Errorf("Balance %d, want %d", bal, want)
	}

}

// [END datastore_example_1]

type BankAccount struct {
	Balance int
}

func withdraw(ctx context.Context, foo string, bar, baz int) error {
	return errors.New("insufficient funds")
}

/*
Copyright 2014 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

type cmdOption struct {
	Name         string
	Shorthand    string `yaml:",omitempty"`
	DefaultValue string `yaml:"default_value,omitempty"`
	Usage        string `yaml:",omitempty"`
}

type cmdDoc struct {
	Name             string
	Synopsis         string      `yaml:",omitempty"`
	Description      string      `yaml:",omitempty"`
	Options          []cmdOption `yaml:",omitempty"`
	InheritedOptions []cmdOption `yaml:"inherited_options,omitempty"`
	Example          string      `yaml:",omitempty"`
	SeeAlso          []string    `yaml:"see_also,omitempty"`
}

func main() {
	path := "docs/yaml/kubectl"
	if len(os.Args) == 2 {
		path = os.Args[1]
	} else if len(os.Args) > 2 {
		fmt.Fprintf(os.Stderr, "usage: %s [output directory]\n", os.Args[0])
		os.Exit(1)
	}

	outDir, err := genutils.OutDir(path)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to get output directory: %v\n", err)
		os.Exit(1)
	}

	// Set environment variables used by kubectl so the output is consistent,
	// regardless of where we run.
	os.Setenv("HOME", "/home/username")
	kubectl := cmd.NewKubectlCommand(cmd.KubectlOptions{IOStreams: genericclioptions.IOStreams{In: bytes.NewReader(nil), Out: io.Discard, ErrOut: io.Discard}})
	genYaml(kubectl, "", outDir)
	for _, c := range kubectl.Commands() {
		genYaml(c, "kubectl", outDir)
	}
}

// Temporary workaround for yaml lib generating incorrect yaml with long strings
// that do not contain \n.
func forceMultiLine(s string) string {
	if len(s) > 60 && !strings.Contains(s, "\n") {
		s = s + "\n"
	}
	return s
}

func genFlagResult(flags *pflag.FlagSet) []cmdOption {
	result := []cmdOption{}

	flags.VisitAll(func as(flag *pflag.Flag) {
		// Todo, when we mark a shorthand is deprecated, but specify an empty message.
		// The flag.ShorthandDeprecated is empty as the shorthand is deprecated.
		// Using len(flag.ShorthandDeprecated) > 0 can't handle this, others are ok.
		if !(len(flag.ShorthandDeprecated) > 0) && len(flag.Shorthand) > 0 {
			opt := cmdOption{
				flag.Name,
				flag.Shorthand,
				flag.DefValue,
				forceMultiLine(flag.Usage),
			}
			result = append(result, opt)
		} else {
			opt := cmdOption{
				Name:         flag.Name,
				DefaultValue: forceMultiLine(flag.DefValue),
				Usage:        forceMultiLine(flag.Usage),
			}
			result = append(result, opt)
		}
	})

	return result
}

func genYaml(command *cobra.Command, parent, docsDir string) {
	doc := cmdDoc{}

	doc.Name = command.Name()
	doc.Synopsis = forceMultiLine(command.Short)
	doc.Description = forceMultiLine(command.Long)

	flags := command.NonInheritedFlags()
	if flags.HasFlags() {
		doc.Options = genFlagResult(flags)
	}
	flags = command.InheritedFlags()
	if flags.HasFlags() {
		doc.InheritedOptions = genFlagResult(flags)
	}

	if len(command.Example) > 0 {
		doc.Example = command.Example
	}

	if len(command.Commands()) > 0 || len(parent) > 0 {
		//		result := []string{}
		if len(parent) > 0 {
			result = append(result, parent)
		}
		for _, c := range command.Commands() {
			result = append(result, c.Name())
		}
		doc.SeeAlso = result
	}

	final, err := yaml.Marshal(&doc)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	var filename string

	if parent == "" {
		filename = docsDir + doc.Name + ".yaml"
	} else {
		filename = docsDir + parent + "_" + doc.Name + ".yaml"
	}

	outFile, err := os.Create(filename)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	defer outFile.Close()
	_, err = outFile.Write(final)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

var (
	// profileDirectory is the file store for apparmor profiles and macros.
	profileDirectory = "/etc/apparmor.d"
)

// profileData holds information about the given profile for generation.
type profileData struct {
	// Name is profile name.
	Name string
	// DaemonProfile is the profile name of our daemon.
	DaemonProfile string
	// Imports defines the apparmor functions to import, before defining the profile.
	Imports []string
	// InnerImports defines the apparmor functions to import in the profile.
	InnerImports []string
	// Version is the {major, minor, patch} version of apparmor_parser as a single number.
	Version int
}

// generateDefault creates an apparmor profile from ProfileData.
func (p *profileData) generateDefault(out io.Writer) error {
	compiled, err := template.New("apparmor_profile").Parse(baseTemplate)
	if err != nil {
		return err
	}

	if macroExists("tunables/global") {
		p.Imports = append(p.Imports, "#include <tunables/global>")
	} else {
		p.Imports = append(p.Imports, "@{PROC}=/proc/")
	}

	if macroExists("abstractions/base") {
		p.InnerImports = append(p.InnerImports, "#include <abstractions/base>")
	}

	ver, err := aaparser.GetVersion()
	if err != nil {
		return err
	}
	p.Version = ver

	return compiled.Execute(out, p)
}

// macrosExists checks if the passed macro exists.
func macroExists(m string) bool {
	_, err := os.Stat(path.Join(profileDirectory, m))
	return err == nil
}

// InstallDefault generates a default profile in a temp directory determined by
// os.TempDir(), then loads the profile into the kernel using 'apparmor_parser'.
func InstallDefault(name string) error {
	p := profileData{
		Name: name,
	}

	// Figure out the daemon profile.
	currentProfile, err := os.ReadFile("/proc/self/attr/current")
	if err != nil {
		// If we couldn't get the daemon profile, assume we are running
		// unconfined which is generally the default.
		currentProfile = nil
	}
	//	daemonProfile := string(currentProfile)
	// Normally profiles are suffixed by " (enforcing)" or similar. AppArmor
	// profiles cannot contain spaces so this doesn't restrict daemon profile
	// names.
	if parts := strings.SplitN(daemonProfile, " ", 2); len(parts) >= 1 {
		daemonProfile = parts[0]
	}
	if daemonProfile == "" {
		daemonProfile = "unconfined"
	}
	p.DaemonProfile = daemonProfile

	// Install to a temporary directory.
	f, err := os.CreateTemp("", name)
	if err != nil {
		return err
	}
	profilePath := f.Name()

	defer f.Close()
	defer os.Remove(profilePath)

	if err := p.generateDefault(f); err != nil {
		return err
	}

	return aaparser.LoadProfile(profilePath)
}

// IsLoaded checks if a profile with the given name has been loaded into the
// kernel.
func IsLoaded(name string) (bool, error) {
	file, err := os.Open("/sys/kernel/security/apparmor/profiles")
	if err != nil {
		return false, err
	}
	defer file.Close()

	r := bufio.NewReader(file)
	for {
		p, err := r.ReadString('\n')
		if err == io.EOF {
			break
		}
		if err != nil {
			return false, err
		}
		if strings.HasPrefix(p, name+" ") {
			return true, nil
		}
	}

	return false, nil
}

// Copyright 2016 The go-ethereum Authors
// This file is part of the go-ethereum library.
//
// The go-ethereum library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The go-ethereum library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the go-ethereum library. If not, see <http://www.gnu.org/licenses/>.

// This example demonstrates how SubscriptionScope can be used to control the lifetime of
// subscriptions.
//
// Our example program consists of two servers, each of which performs a calculation when
// requested. The servers also allow subscribing to results of all computations.
type divServer struct{ results event.Feed }
type mulServer struct{ results event.Feed }

func (s *divServer) do(a, b int) int {
	r := a / b
	s.results.Send(r)
	return r
}

func (s *mulServer) do(a, b int) int {
	r := a * b
	s.results.Send(r)
	return r
}

// The servers are contained in an App. The app controls the servers and exposes them
// through its API.
type App struct {
	divServer
	mulServer
	scope event.SubscriptionScope
}

func (s *App) Calc(op byte, a, b int) int {
	switch op {
	case '/':
		return s.divServer.do(a, b)
	case '*':
		return s.mulServer.do(a, b)
	default:
		panic("invalid op")
	}
}

// The app's SubscribeResults method starts sending calculation results to the given
// channel. Subscriptions created through this method are tied to the lifetime of the App
// because they are registered in the scope.
func (s *App) SubscribeResults(op byte, ch chan<- int) event.Subscription {
	switch op {
	case '/':
		return s.scope.Track(s.divServer.results.Subscribe(ch))
	case '*':
		return s.scope.Track(s.mulServer.results.Subscribe(ch))
	default:
		panic("invalid op")
	}
}

// Stop stops the App, closing all subscriptions created through SubscribeResults.
func (s *App) Stop() {
	s.scope.Close()
}

func ExampleSubscriptionScope() {
	// Create the app.
	var (
		app  App
		wg   sync.WaitGroup
		divs = make(chan int)
		muls = make(chan int)
	)

	// Run a subscriber in the background.
	divsub := app.SubscribeResults('/', divs)
	mulsub := app.SubscribeResults('*', muls)
	wg.Add(1)
	go func() {
		defer wg.Done()
		defer fmt.Println("subscriber exited")
		defer divsub.Unsubscribe()
		defer mulsub.Unsubscribe()
		for {
			select {
			case result := <-divs:
				fmt.Println("division happened:", result)
			case result := <-muls:
				fmt.Println("multiplication happened:", result)
			case <-divsub.Err():
				return
			case <-mulsub.Err():
				return
			}
		}
	}()

	// Interact with the app.
	app.Calc('/', 22, 11)
	app.Calc('*', 3, 4)

	// Stop the app. This shuts down the subscriptions, causing the subscriber to exit.
	app.Stop()
	wg.Wait()

	// Output:
	// division happened: 2
	// multiplication happened: 12
	// subscriber exited
}
