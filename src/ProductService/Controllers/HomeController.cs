using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace ProductService.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
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
            return Content("123");
        }

        public IActionResult Add([FromBody] dynamic data)
        {
            dynamic json = JsonConvert.DeserializeObject(data.ToString());
            return Content($"a:{json.a.ToString()},b:{json.b.ToString()}");
        }

        public IActionResult New([FromBody] User user)
        {
            return Content($"Name:{user.Name},Age:{user.Age}");
        }
    }

    public class User
    {
        public string Name { get; set; }
        public string Age { get; set; }
    }
}
