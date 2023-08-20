using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Lib01.Configs;

namespace Customer.EventHandler
{
    internal class Program
    {
        static async Task Main()
        {
            var builder = new HostBuilder();
            //builder.ConfigureHostConfiguration((config) =>
            //{
            //    ConfigLoader.LoadConfiguration(config);
            //});
            builder.ConfigureAppConfiguration((config) =>
            {
                ConfigLoader.LoadConfiguration(config);
            });
            builder.ConfigureLogging((context, b) =>
            {
                b.AddConsole();
            });
            builder.ConfigureWebJobs(b =>
            {
                b.AddEventHubs();
            });
            var host = builder.Build();
            using (host)
            {
                await host.RunAsync();
            }
        }
    }
}