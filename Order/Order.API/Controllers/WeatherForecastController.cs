using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using Lib01.Configs;
using Lib01.Sql;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using System.Text;

namespace Order.API.Controllers;

[ApiController]
[Route("api")]
public class WeatherForecastController : ControllerBase
{
    private readonly Settings _settings;
    
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;
    private readonly EventHubProducerClient _eventhubClient;
    
    public WeatherForecastController(ILogger<WeatherForecastController> logger, IOptionsSnapshot<Settings> options, IConfiguration config, EventHubProducerClient eventHubClient)
    {
        _logger = logger;
        _settings = options.Value;
        _eventhubClient = eventHubClient;
        
        // Just a test
        string sqlCon = config.GetValue<string>("SqlDBConnection");
    }

    [HttpGet("forecast")]
    public IEnumerable<WeatherForecast> Get()
    {
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateTime.Now.AddDays(index),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray();
    }

    [HttpGet("forecastcount")]
    public int GetForecastCount()
    {
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateTime.Now.AddDays(index),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray().Count();
    }

    [HttpGet("health")]
    public IEnumerable<WeatherForecast> GetHealth()
    {
        // returns same forecast data as health api
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateTime.Now.AddDays(index),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray();
    }

    [HttpGet("configtest")]
    public string GetConfigtest()
    {
        return string.IsNullOrWhiteSpace(_settings.EventHubConsumer1) ? "setting is null" : _settings.EventHubConsumer1;
    }

    [HttpGet("neworder")]
    public async Task<string> NewOrder()
    {
        DateTime timeNow = TimeZoneInfo.ConvertTime(DateTime.Now, TimeZoneInfo.FindSystemTimeZoneById("Central Europe Standard Time")); // Linux CET Win Central Europe Standard Time
        string msgId = timeNow.ToString("dd-MM-yyyy-HH:mm:ss.fffffff-tt");

        await SqlCommanRunner.RunAsync(_settings.SqlDBConnection,
            $"INSERT INTO dbo.[Order] ([Number],[Status],[InitiatedByApp],[InitiatedByCluster],[IntiatedAt]) VALUES ('{msgId}','Initiated','Order.API','{_settings.AppConfigLabel}','{timeNow.ToString("MM/dd/yyyy HH:mm:ss.fff tt")}')");
        
        using EventDataBatch eventBatch = await _eventhubClient.CreateBatchAsync();
        eventBatch.TryAdd(new EventData()
        {
            MessageId = msgId,
            EventBody = new BinaryData(Encoding.UTF8.GetBytes($"New order {msgId}"))
        });
        await _eventhubClient.SendAsync(eventBatch);
        
        return $"New order intiated {msgId}";
    }
}
