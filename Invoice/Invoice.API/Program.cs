using Azure.Messaging.EventHubs.Producer;
using Invoice.API;
using Lib01.Configs;
using Microsoft.AspNetCore.Rewrite;

var builder = WebApplication.CreateBuilder(args);
ConfigLoader.LoadConfiguration(builder.Configuration);

// Bind configuration all configs to the Settings object
builder.Services.Configure<Settings>(builder.Configuration);

builder.Services.AddSingleton<EventHubProducerClient>(new EventHubProducerClient(builder.Configuration.GetValue<string>("EventHubPublisher2"), "newinvoice"));


// Make code change
// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// //string appConfigSVC = new Random().Next(1, 99) % 2 == 0 ? "https://appcs-demo-temp01.azconfig.io" : "https://appcs-demo-temp011.azconfig.io";
// string appConfigSVC = "https://appcs-demo-temp01.azconfig.io";
// builder.Configuration.AddAzureAppConfiguration(options =>
//     options
//         .Connect($"Endpoint={appConfigSVC};Id=r+BC-l0-s0:cEdvPcN7w0eQRQ/0rrfB;Secret=nIeVZgBFPZv6JB4yO5d8kEz8t0255U5lxcgaqrA6Y00=")
//     );

// // Bind configuration "TestApp:Settings" section to the Settings object
// builder.Services.Configure<Settings>(builder.Configuration.GetSection("TestApp:Settings"));

var app = builder.Build();

// Configure the HTTP request pipeline.
// if (app.Environment.IsDevelopment())
// {
    // app.UseSwagger(c =>
    // {
    //     c.RouteTemplate = "invoice/api/swagger/{documentname}/swagger.json";
    // });
    // app.UseSwaggerUI(c =>
    // {
    //     c.SwaggerEndpoint("/invoice/api/swagger/v1/swagger.json", "Invoice.API V1");
    //     c.RoutePrefix = "invoice/api/swagger";
    // });
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Invoice.API V1");
    });
// }

app.UseHttpsRedirection();

app.UseRewriter(GetRewriteOptions());

app.UseAuthorization();

app.MapControllers();

app.Run();

static RewriteOptions GetRewriteOptions()
{
    RewriteOptions options = new RewriteOptions();

    using StreamReader iisUrlRewriteStreamReader = File.OpenText("UrlRewriteDocker.xml");

    options.AddIISUrlRewrite(iisUrlRewriteStreamReader);

    return options;
}