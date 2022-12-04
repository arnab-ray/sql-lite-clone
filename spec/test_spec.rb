RSpec.describe 'database' do
  before do
    `rm -rf test.db`
  end

  def run_script(commands)
    raw_output = nil
    IO.popen("./database", "r+") do |pipe|
      commands.each do |command|
        pipe.puts command
      end

      pipe.close_write

      raw_output = pipe.gets(nil)
    end
    raw_output.split("\n")
  end

  it 'inserts and fetches a row' do
    result = run_script([
      "insert 1 user1 foo@test.com",
      "select",
      ".exit",
    ])
    expect(result).to match_array([
      "db> Executed.",
      "db> (1, user1, foo@test.com)",
      "Executed.",
      "db> ",
    ])
  end

  it 'print error message if table is full' do
    script = (1..1401).map do |i|
      "insert #{i} user#{i} user#{i}@test.com"
    end
    script << ".exit"
    result = run_script(script)
    expect(result[-2]).to eq('db> Error: Table full.')
  end
end
