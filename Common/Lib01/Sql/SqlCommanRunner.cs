using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Lib01.Sql
{
    public class SqlCommanRunner
    {
        public async static Task RunAsync(string connectionString, string command)
        {
            using SqlConnection con = new(connectionString);
            con.Open();
            using SqlCommand cmd = new (command, con);
            await cmd.ExecuteNonQueryAsync();
            await con.CloseAsync();
        }
    }
}
