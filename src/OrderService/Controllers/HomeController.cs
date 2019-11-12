using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Consul;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using OrderService.Common;

namespace OrderService.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private IConfiguration _configuration;

        public HomeController(ILogger<HomeController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Health()
        {
            return Ok();
        }

        public IActionResult Test()
        {
            string content = "Order调用Auth和Product";
            var consulService = new ConsulService(_configuration);
            content += consulService.GetAsync("AuthService", "test/index").Result;

            content += consulService.GetAsync("ProductService", "home/test").Result;



            return Content(content);
        }

        public async Task<IActionResult> TestPostAsync()
        {
            string content = "Order调用Post \n";
            var consulService = new ConsulService(_configuration);

            var user = new User() { Name = "123", Age = "456" };
            content += consulService.PostAsync("ProductService", "home/add", JsonConvert.SerializeObject(new { a = "aaa", b = "bbb" })).Result;
            content += "\n";
            content += consulService.PostAsync("ProductService", "home/new", JsonConvert.SerializeObject(user)).Result;

            using (System.Net.Http.HttpClient http = new HttpClient())
            {
                using var HttpContent = new StringContent(JsonConvert.SerializeObject(user), System.Text.Encoding.UTF8, "application/json");
                var ss = http.PostAsync($"http://localhost:10100/home/new", HttpContent);
                var result = ss.Result.Content;
                content += await result.ReadAsStringAsync();
            }

            return Content(content);

        }
    }

    public class User
    {
        public string Name { get; set; }
        public string Age { get; set; }
    }
}
