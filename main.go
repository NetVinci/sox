package main

import (
	"flag"
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
)

// HostsStruct is a simple struct to decode our YAML file that
// is read in as a configuration. The configuration should look like
// hosts:
//   - public: my.publichost.com/
//     private: http://192.168.1.1:9876
//
// We can now set DNS and it will handle the proxy based on the
// virtual host address to the private address and port number.
type HostsStruct struct {
	Hosts []struct {
		Public  string `yaml:"public"`
		Private string `yaml:"private"`
	} `yaml:"hosts"`
}

func main() {
	config := flag.String("config", "./hosts.yaml", "config file for usage.")
	flag.Parse()

	yamlFile, err := ioutil.ReadFile(*config)
	if err != nil {
		log.Fatalln( err)
	}
	hStruct := HostsStruct{}
	err = yaml.Unmarshal(yamlFile, &hStruct)
	if err != nil {
		log.Fatalf("Unmarshal: %v", err)
	}

	for _, v := range hStruct.Hosts {
		host, err := url.Parse(v.Private)
		if err != nil {
			log.Fatalln(err)
		}
		proxy := httputil.NewSingleHostReverseProxy(host)
		http.HandleFunc(v.Public, handler(proxy))
	}

	err = http.ListenAndServe(":80", nil)
	if err != nil {
		panic(err)
	}
}

func handler(p *httputil.ReverseProxy) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		p.ServeHTTP(w, r)
	}
}