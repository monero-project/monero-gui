/**********************************************************************************
 * Program to generate the dictionary for the C implementation of the zxcvbn password estimator.
 * Copyright (c) 2015, Tony Evans
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list
 *    of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this
 *    list of conditions and the following disclaimer in the documentation and/or other
 *    materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be
 *    used to endorse or promote products derived from this software without specific
 *    prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 **********************************************************************************/

#include <iostream>
#include <string>
#include <fstream>
#include <list>
#include <set>
#include <vector>
#include <map>
#include <memory>
#include <limits>
#include <stdlib.h>
#include <string.h>
#include <math.h>

using namespace std;

class Node;
typedef std::shared_ptr<Node> NodeSPtr;
typedef std::weak_ptr<Node> NodeWPtr;
typedef std::map<char, NodeSPtr> NodeMap_t;

typedef unsigned int Check_t;

/**********************************************************************************
 * Class to perform CRC checksum calculation.
 */
class TrieCheck
{
public:
    typedef uint64_t Check_t;
    static const Check_t CHK_INIT = 0xffffffffffffffff;
    TrieCheck()          { Init(); }
    void Init()          { mCrc = CHK_INIT; }
    operator Check_t() const { return Result(); }
    Check_t  Result()  const { return mCrc; }
    bool operator ! () const { return mCrc == CHK_INIT; }
    void operator () (const void *, unsigned int);
protected:
    Check_t mCrc;
};

/**********************************************************************************
 * Class to hold a node within the trie
 */
class Node
{
public:
    Node();
    Node(const Node &);
    ~Node();
    Node & operator = (const Node &);
    //bool operator == (const Node & r) const { return !IsEqual(r); }
    //bool operator != (const Node & r) const { return !IsEqual(r); }
    void          SetEnd()           { mEnd = true; }
    bool          IsEnd() const      { return mEnd; }
    int           Height() const     { return mHeight; }

    // Scan the trie and count nodes
    int           NodeCount()        { ClearCounted() ; return CountNodes(); }


    int           CalcAddress()      { int a=0; ClearCounted(); a=CalcAddr(a, true); return CalcAddr(a, false); }
    Node         *GetParent()        { return mParent; }
    unsigned int  GetAddr() const    { return mAddr; }
    NodeMap_t::iterator ChildBegin() { return mChild.begin(); }
    NodeMap_t::iterator ChildEnd()   { return mChild.end(); }
    int           GetNumEnds() const { return mEndings; }
    NodeSPtr      FindChild(char);
    std::string   GetChildChars();

    TrieCheck::Check_t CalcCheck();
    int         CalcEndings();
    int         CalcHeight();
    NodeSPtr    AddChild(char);
    void        ChangeChild(NodeSPtr &, NodeSPtr &);
//    bool        IsEqual(const Node &) const;
    void        ClearCounted();
    void        SetCounted()    { mCounted = true; }
    bool        IsCounted() const { return mCounted; }
protected:
    int      CountNodes();
    int      CalcAddr(int, bool);

    NodeMap_t    mChild;
    Node        *mParent;
    int          mEndings;
    int          mHeight;
    unsigned int mAddr;
    TrieCheck    mCheck;
    bool         mEnd;
    bool         mCounted;
};

/**********************************************************************************
 * Static table used for the crc implementation.
 */
static const TrieCheck::Check_t CrcTable[16] =
{
    0x0000000000000000, 0x7d08ff3b88be6f81, 0xfa11fe77117cdf02, 0x8719014c99c2b083,
    0xdf7adabd7a6e2d6f, 0xa2722586f2d042ee, 0x256b24ca6b12f26d, 0x5863dbf1e3ac9dec,
    0x95ac9329ac4bc9b5, 0xe8a46c1224f5a634, 0x6fbd6d5ebd3716b7, 0x12b5926535897936,
    0x4ad64994d625e4da, 0x37deb6af5e9b8b5b, 0xb0c7b7e3c7593bd8, 0xcdcf48d84fe75459
};

// Update the crc value with new data.
void TrieCheck::operator () (const void *v, unsigned int Len)
{
    Check_t Crc = mCrc;
    const unsigned char *Data = reinterpret_cast<const unsigned char *>(v);
    while(Len--)
    {
        Crc = CrcTable[(Crc ^ (*Data >> 0)) & 0x0f] ^ (Crc >> 4);
        Crc = CrcTable[(Crc ^ (*Data >> 4)) & 0x0f] ^ (Crc >> 4);
        ++Data;
    }
    mCrc = Crc;
}

Node::Node()
{
    mEndings = -1;
    mHeight = -1;
    mEnd    = false;
    mParent = 0;
}

Node::Node(const Node &r)
{
    *this = r;
}

Node::~Node()
{

}

Node &Node::operator = (const Node & r)
{
    mChild   = r.mChild;
    mParent  = r.mParent;
    mEndings = r.mEndings;
    mHeight  = r.mHeight;
    mCheck   = r.mCheck;
    mEnd     = r.mEnd;
    return *this;
}


/**********************************************************************************
 * Generate a checksum for the current node. Value also depends of the
 * checksum of any child nodes
 */
TrieCheck::Check_t Node::CalcCheck()
{
    if (!mCheck)
    {
        // Not done this node before
        char c;
        NodeMap_t::iterator It;
        mCheck.Init();
        // Include number of children
        c = mChild.size();
        mCheck(&c, sizeof c);
        // For each child include its character and node checksum
        for(It = mChild.begin(); It != mChild.end(); ++It)
        {
            Check_t n = It->second->CalcCheck();
            c = It->first;
            mCheck(&c, sizeof c);
            mCheck(&n, sizeof n);
        }
        // Finally include whether this node is an ending in the chaecksum
        c = mEnd;
        mCheck(&c, sizeof c);
    }
    return mCheck;
}

/**********************************************************************************
 * Get number of nodes for this which end/finish a word
 */
int Node::CalcEndings()
{
    if (mEndings < 0)
    {
        // Not already done this node,so calculate the ends
        int n = 0;
        NodeMap_t::iterator It;
        // Number of endings is sum of the endings of the child nodes and plus this node if it ends a word
        for(It = mChild.begin(); It != mChild.end(); ++It)
            n += It->second->CalcEndings();
        n += !!mEnd;
        mEndings = n;
    }
    return mEndings;
}

/**********************************************************************************
 * Calculate the height of the trie starting at current node
 */
int Node::CalcHeight()
{
    if (mHeight < 0)
    {
        // Not already done this node,so calculate the height
        int Hi = 0;
        NodeMap_t::iterator It;
        // Get height of all child nodes, remember the highest
        for(It = mChild.begin(); It != mChild.end(); ++It)
        {
            int i = It->second->CalcHeight();
            if (i >= Hi)
                Hi = i+1;
        }
        mHeight = Hi;
    }
    return mHeight;
}

/**********************************************************************************
 * Clear indication that node has been counted
 */
void Node::ClearCounted()
{
    NodeMap_t::iterator It;
    mCounted = false;
    for(It = mChild.begin(); It != mChild.end(); ++It)
        It->second->ClearCounted();
}

/**********************************************************************************
 * Count this plus the number of child nodes. As part of the tree node count
 * scan, make sure not to double count nodes
 */
int Node::CountNodes()
{
    // Count is 0 if already done
    if (mCounted)
        return 0;
    mCounted = true;
    NodeMap_t::iterator It;
    int i = 1; // 1 for this node

    // Add the child nodes
    for(It = mChild.begin(); It != mChild.end(); ++It)
        i += It->second->CountNodes();
    return i;
}

/**********************************************************************************
 * Calculate the final node address
 */
int Node::CalcAddr(int Start, bool ManyEnds)
{
    NodeMap_t::iterator It;

    if (!(mCounted || (ManyEnds && (mEndings < 256))))
    {
        mCounted = true;
        mAddr = Start++;
    }
    for(It = mChild.begin(); It != mChild.end(); ++It)
        Start = It->second->CalcAddr(Start, ManyEnds);

    return Start;
}

/**********************************************************************************
 * Add the given character to the current node, return the next lower node
 */
NodeSPtr Node::AddChild(char c)
{
    NodeMap_t::iterator It;
    // Find character in map of child nodes
    It = mChild.find(c);
    if (It == mChild.end())
    {
        // New character, create new child node
        NodeSPtr a(new Node);
        a->mParent = this;
        std::pair<char, NodeSPtr> x(c, a);
        std::pair<NodeMap_t::iterator, bool> y = mChild.insert(x);
        It = y.first;
    }
    return It->second;
}

/**********************************************************************************
 * Find the child node which corresponds to the given character.
 */
NodeSPtr Node::FindChild(char Ch)
{
    NodeMap_t::iterator It;
    It = mChild.find(Ch);
    if (It == mChild.end())
        return NodeSPtr();
    return It->second;
}

/**********************************************************************************
 * Replace the current child node (old param) with a new child (Replace param),
 * and update the new child parent.
 */
void Node::ChangeChild(NodeSPtr & Replace, NodeSPtr & Old)
{
    NodeMap_t::iterator It;
    for(It = mChild.begin(); It != mChild.end(); ++It)
    {
        NodeSPtr p = It->second;
        if (p == Old)
        {
            It->second = Replace;
            Replace->mParent = this;
            break;
        }
    }
}

/**********************************************************************************
 * Find all the characters corresponding to the children of this node.
 */
std::string Node::GetChildChars()
{
    NodeMap_t::iterator It;
    std::string Result;
    for(It = mChild.begin(); It != mChild.end(); ++It)
    {
        char c = It->first;
        Result += c;
    }
    return Result;
}

/**********************************************************************************
 * struct to hold data read from input file (except for the word string)
 */
struct Entry
{
    Entry() : mRank(0), mDict(0), mOrder(0), mOccurs(0) {}
    int mRank;
    int mDict;
    int mOrder;
    int mOccurs;
};

/**********************************************************************************
 * Struct to hold a string and an int. Also provide the compare operators for std::set class
 */
struct StringInt
{
    string       s;
    unsigned int i;
    StringInt() { i=0; }
    StringInt(const StringInt & r) : s(r.s), i(r.i) {}
    StringInt & operator = (const StringInt & r) { i = r.i; s = r.s; return *this; }
    bool operator < (const StringInt & r)  const { return s < r.s; }
    bool operator > (const StringInt & r)  const { return s > r.s; }
    bool operator == (const StringInt & r) const { return s == r.s; }
    StringInt * Self() const { return const_cast<StringInt *>(this); }
};

typedef map<string, Entry> EntryMap_t;
typedef list<string> StringList_t;
typedef list<NodeSPtr> NodeList_t;
typedef set<StringInt> StringIntSet_t;
typedef basic_string<int> StringOfInts;
typedef vector<unsigned int> UintVect;
typedef vector<uint64_t> Uint64Vect;
typedef vector<StringInt *> StrIntPtrVect_t;
typedef vector<StringInt> StringIntVect_t;

// Variables holding 'interesting' information on the data
unsigned int MaxLength, MinLength, NumChars, NumInWords, NumDuplicate;
struct FileInfo
{
    FileInfo() : Words(0), BruteIgnore(0), Accented(0), Dups(0), Used(0), Rank(0) { }
    string Name;
    StringList_t Pwds;
    int Words;
    int BruteIgnore;
    int Accented;
    int Dups;
    int Used;
    int Rank;
};

/**********************************************************************************
 * Read the file of words and add them to the file information.
 */
static bool ReadInputFile(const string & FileName, FileInfo &Info, int MaxRank)
{
    ifstream f(FileName.c_str());
    if (!f.is_open())
    {
        cerr << "Error opening " << FileName << endl;
        return false;
    }
    Info.Name = FileName;

    // Rank is the position of the work in the dictionary file. Rank==1 is lowest for a word (and
    // indicates a very popular or bad password).
    int Rank = 0;
    string Line;
    while(getline(f, Line) && (Rank < MaxRank))
    {
        // Truncate at first space or tab to leave just the word in case additional info on line
        string::size_type y = Line.find_first_of("\t ");
        if (y != string::npos)
            Line.erase(y);

        y = Line.length();
        if (!y)
            continue;

        ++Info.Words;
        // Only use words where all chars are ascii (no accents etc.)
        string::size_type x;
        double BruteForce = 1.0;
        for(x = 0; x < y; ++x)
        {
            unsigned char c = Line[x];
            if (c >= 128)
                break;
            c = tolower(c);
            Line[x] = c;
            BruteForce *= 26.0;
        }
        if (x < y)
        {
            ++Info.Accented;
            continue;
        }

        // Don't use words where the brute force strength is less than the word's rank
        if (BruteForce < (Rank+1))
        {
            ++Info.BruteIgnore;
            continue;
        }
        // Remember some interesting info
        if (y > MaxLength)
            MaxLength = y;
        if (y < MinLength)
            MinLength = y;
        NumChars += y;

        Info.Pwds.push_back(Line);
        ++Rank;
    }
    f.close();
    return true;
}

static void CombineWordLists(EntryMap_t & Entries, FileInfo *Infos, int NumInfo)
{
    bool Done = false;
    int Rank = 0;
    while(!Done)
    {
        int i;
        ++Rank;
        Done = true;
        for(i = 0; i < NumInfo; ++i)
        {
            FileInfo *p = Infos + i;
            while(!p->Pwds.empty())
            {
                Done = false;
                string Word = p->Pwds.front();
                p->Pwds.pop_front();
                EntryMap_t::iterator It = Entries.find(Word);
                if (It != Entries.end())
                {
                    // Word is repeat of one from another file
                    p->Dups += 1;
                    ++NumDuplicate;
                }
                else
                {
                    // New word, add it
                    Entry e;
                    e.mDict = i;
                    e.mRank = Rank;
                    Entries.insert(std::pair<std::string, Entry>(Word, e));
                    p->Used += 1;
                    break;
                }
            }
        }
    }
}

/**********************************************************************************
 * Use all words previously read from file(s) and add them to a Trie, which starts
 * at Root. Also update a bool array indicating the chars used in the words.
 */
static void ProcessEntries(NodeSPtr Root, EntryMap_t & Entries, bool *InputCharSet)
{
    EntryMap_t::iterator It;
    std::string Text;
    for(It = Entries.begin(); It != Entries.end(); ++It)
    {
        Text = It->first;
        // Add latest word to tree
        string::size_type x;
        NodeSPtr pNode = Root;
        for(x = 0; x < Text.length(); ++x)
        {
            char c = Text[x];
            pNode = pNode->AddChild(c);
            // Add char to set of used character codes
            InputCharSet[c & 0xFF] = true;
        }
        pNode->SetEnd();
    }
}

/**********************************************************************************
 * Add the passed node to the list if it has same height  as value in Hi (= number
 * of steps to get to a terminal node). If current node has height greater than Hi,
 * recursivly call with each child node as one of these may be at the required height.
 */
static void AddToListAtHeight(NodeList_t & Lst, NodeSPtr Node, int Hi)
{
    if (Hi == Node->Height())
    {
        Lst.push_back(Node);
        return;
    }
    if (Hi < Node->Height())
    {
        NodeMap_t::iterator It;
        for(It = Node->ChildBegin(); It != Node->ChildEnd(); ++It)
        {
            AddToListAtHeight(Lst, It->second, Hi);
        }
    }
}

/**********************************************************************************
 * Scan the trie and update the original word list with the alphabetical order
 * (or 'index location') of the words
 */
static void ScanTrieForOrder(EntryMap_t & Entries, int & Ord, NodeSPtr Root, const string & Str)
{
    if (Root->IsEnd())
    {
        // Root is a word ending node, so store its index in the input word store
        EntryMap_t::iterator Ite;
        Ite = Entries.find(Str);
        if (Ite == Entries.end())
            throw "Trie string not in entries";

        Ite->second.mOrder = ++Ord;
    }
    NodeMap_t::iterator It;
    string Tmp;
    // For each child, append its character to the current word string and do a recursive
    // call to update their word indexes.
    for(It = Root->ChildBegin(); It != Root->ChildEnd(); ++It)
    {
        Tmp = Str + It->first;
        ScanTrieForOrder(Entries, Ord, It->second, Tmp);
    }
}

/**********************************************************************************
 * Reduce the trie by merging tails where possible. Starting at greatest height,
 * get a list of all nodes with given height, then test for identical nodes. If
 * found, change the parent of the second identical node to use the first node,
 * and delete second node and its children. Reduce height by one and repeat
 * until height is zero.
 */
static void ReduceTrie(NodeSPtr Root)
{
    int Height;
    int cnt=0, del=0;
    Root->CalcCheck();

    NodeSPtr pNode = Root;
    for(Height = Root->CalcHeight(); Height >= 0; --Height)
    {
        // Get a list of all nodes at given height
        int x=0;
        NodeList_t Lst;
        AddToListAtHeight(Lst, Root, Height);
        cnt += Lst.size();

        NodeList_t::iterator Ita, Itb;
        for(Ita = Lst.begin(); Ita != Lst.end(); ++Ita)
        {
            // Going to use a CRC to decide if two nodes are identical
            TrieCheck::Check_t Chka = (*Ita)->CalcCheck();
            Itb = Ita;
            for(++Itb; Itb != Lst.end(); )
            {
                if (Chka == (*Itb)->CalcCheck())
                {
                    // Found two identical nodes (with identical children)
                    Node * Parentb = (*Itb)->GetParent();
                    if (Parentb)
                    {
                        // Change the 2nd parent to use the current node as child
                        // Remove the 2nd node from the scanning list to as it will
                        // get deleted by the sharing (as using std::shared_ptr)
                        Parentb->ChangeChild(*Ita, *Itb);
                        ++x;++del;
                        Itb = Lst.erase(Itb);
                    }
                    else
                    {
                        cout << " orphan ";
                        ++Itb;
                    }
                }
                else
                {
                    ++Itb;
                }
            }
        }
    }
}

/**********************************************************************************
 * Scan the trie to match with the supplied word. Return the order of the
 * word, or -1 if it is not in the trie.
 */
static int CheckWord(NodeSPtr Root, const string & Str)
{
    int i = 1;
    bool e = false;
    string::size_type x;
    NodeSPtr p = Root;

    for(x = 0; x < Str.length(); ++x)
    {
        int j;
        NodeMap_t::iterator It;
        // Scan children to find one that matches current character
        char c = Str[x];
        for(It = p->ChildBegin(); It != p->ChildEnd(); ++It)
        {
            if (It->first == c)
                break;
            // Add the number of endings at or below child to track the alphabetical index
            j = It->second->CalcEndings();
            i += j;
        }
        // Fail if no child matches the character
        if (It == p->ChildEnd())
            return -1;
        // Allow for this node being a word ending
        e = p->IsEnd();
        if (e)
            ++i;

        p = It->second;
    }

    if (p && p->IsEnd())
    {
        if (x == Str.length())
            return i;
    }
    return -1;
}

/**********************************************************************************
 * Try to find every input word in the reduced trie. The order should also
 * match, otherwise the reduction has corrupted the trie.
 */
static int CheckReduction(StringIntVect_t & Ranks, NodeSPtr Root, EntryMap_t & Entries)
{
    int i = 0;
    int n = 0;
    EntryMap_t::iterator It;
    std::string Text;
    int b;
    Ranks.resize(Entries.size()+1);
    for(It = Entries.begin(); (It != Entries.end()) && (i <= 200000); ++It)
    {
        Text = It->first;
        b = CheckWord(Root, Text);
        if (b < 0)
        {
            ++i;
            cout << It->second.mOrder << ": Missing " << Text.c_str() << endl;
        }
        else if (It->second.mOrder != b)
        {
            ++i;
            cout << It->second.mOrder << ": Bad order " << b << " for  " << Text.c_str() << endl;
        }
        else
        {
            //if (Text == "fred")
            //    cout << Text.c_str() << "-> " << It->second.mOrder << ", " << It->second.mRank << endl;
            ++n;
        }
        if (b >= int(Ranks.size()))
            throw " Using  Ranks beyond end";
        if (b >= 0)
        {
            char Tmp[20];
            Ranks[b].i = It->second.mRank;
            sprintf(Tmp, "%d: ", n);
            Ranks[b].s = string(Tmp) + Text;
        }
        // Try to find a non-existant word
        Text.insert(0, "a");
        Text += '#';
        b = CheckWord(Root, Text);
        if (b > 0)
            throw string("Found non-existant word ") + Text;
     }
     if (i > 0)
         throw "Missing words in reduction check = " + to_string(i);
    return n;
}

struct ChkNum
{
    int Match;
    int Err;
    ChkNum() : Match(0), Err(0) {}
    ChkNum(const ChkNum &r) : Match(r.Match), Err(r.Err) {}
    ChkNum & operator = (const ChkNum & r) { Match = r.Match; Err = r.Err; return *this; }
    ChkNum & operator += (const ChkNum & r) { Match += r.Match; Err += r.Err; return *this; }
};

/**********************************************************************************
 * Find all possible words in the trie and make sure they are input words.
 * Return number of words found. Done as a second trie check.
 */
static ChkNum CheckEntries(NodeSPtr Root, string Str, const EntryMap_t & Entries)
{
    ChkNum Ret;
    if (Root->IsEnd())
    {
        // This is an end node, find the word in the input words
        EntryMap_t::const_iterator It = Entries.find(Str);
        if (It != Entries.end())
            ++Ret.Match;
        else
            ++Ret.Err;
    }
    // Add each child character to the passed string and recursively check
    NodeMap_t::iterator It;
    for(It = Root->ChildBegin(); It != Root->ChildEnd(); ++It)
    {
        string Tmp = Str;
        Tmp += It->first;
        Ret += CheckEntries(It->second, Tmp, Entries);
    }
    return Ret;
}

/**********************************************************************************
 * Convert the passed bool array of used chars into a character string
 */
string MakeCharSet(bool *InputCharSet)
{
    int i;
    string s;
    for(i = 1; i < 256; ++i)
    {
        if (InputCharSet[i])
            s += char(i);
    }
    return s;
}

/**********************************************************************************
 * Create a set of strings which contain the possible characters matched at
 * a node when checking a word.
 */
void MakeChildBitMap(StringIntSet_t & StrSet, NodeSPtr Root, int & Loc)
{
    // Skip if already done
    if (Root->IsCounted())
        return;

    string::size_type x;
    StringInt In;
    NodeSPtr p = Root;
    In.s = Root->GetChildChars();
    if (StrSet.find(In) == StrSet.end())
    {
        // Not already in set of possible child chars for a node, so add it
        In.i = Loc++; // Address in the final output array
        StrSet.insert(In);
    }
    // Recursively do the child nodes
    for(x = 0; x < In.s.length(); ++x)
    {
        char c = In.s[x];
        NodeSPtr q = p->FindChild(c);
        if (q)
            MakeChildBitMap(StrSet, q, Loc);
    }
    Root->SetCounted();
}

// Constants defining bit positions of node data
// Number of bits to represent the index of the child char pattern in the final child bitmap array,
const int BITS_CHILD_PATT_INDEX = 14;

// Number of bits to represent index of where the child pointers start for this node in
// the Child map array and its bit position
const int BITS_CHILD_MAP_INDEX = 18;
const int SHIFT_CHILD_MAP_INDEX = BITS_CHILD_PATT_INDEX;

// Bit positions of word ending indicator and indicator for number of word endings for this + child nodes is >= 256
const int SHIFT_WORD_ENDING_BIT = SHIFT_CHILD_MAP_INDEX + BITS_CHILD_MAP_INDEX;
const int SHIFT_LARGE_ENDING_BIT = SHIFT_WORD_ENDING_BIT + 1;
/**********************************************************************************
 * Create the arrays of data that will be output
 */
void CreateArrays(NodeSPtr Root, StringIntSet_t & StrSet, StringOfInts & ChildAddrs, Uint64Vect & NodeData, UintVect & NodeEnds)
{
    NodeMap_t::iterator Itc;
    StringInt Tmp;
    StringOfInts Chld;

    // Find children in the child pattern array
    Tmp.s= Root->GetChildChars();
    StringIntSet_t::iterator Its = StrSet.find(Tmp);

    // Make a 'string' of pointers to the children
    for(Itc = Root->ChildBegin(); Itc != Root->ChildEnd(); ++Itc)
    {
        int i = Itc->second->GetAddr();
        Chld += i;
    }
    // Find where in pointer array the child pointer string is
    StringOfInts::size_type x = ChildAddrs.find(Chld);
    if (x == StringOfInts::npos)
    {
        // Not found, add it
        x = ChildAddrs.length();
        ChildAddrs += Chld;
    }
    // Val will contain the final node data
    uint64_t Val = Its->i;
    if (Val >= (1 << BITS_CHILD_PATT_INDEX))
    {
        char Tmp[20];
        snprintf(Tmp, sizeof Tmp, "%u", Its->i);
        throw string("Not enough bits for child pattern index value of ") + Tmp + " for " +
                Its->s + " (BITS_CHILD_PATT_INDEX too small)";
    }
    if (x >= (1 << BITS_CHILD_MAP_INDEX))
    {
        char Tmp[20];
        snprintf(Tmp, sizeof Tmp, "%lu", x);
        throw string("Not enough bits for child map index value of ") + Tmp + " for " +
                Its->s + " (BITS_CHILD_MAP_INDEX too small)";
    }
    Val |= x << SHIFT_CHILD_MAP_INDEX;
    if (Root->IsEnd())
        Val |= uint64_t(1) << SHIFT_WORD_ENDING_BIT;
    if (Root->GetNumEnds() >= 256)
        Val |= uint64_t(1) << SHIFT_LARGE_ENDING_BIT;

    // Make sure output arrays are big enough
    if (Root->GetAddr() > NodeData.size())
    {
        NodeData.resize(Root->GetAddr()+1, 4000000000);
        NodeEnds.resize(Root->GetAddr()+1, 4000000000);
    }
    // Save the node data and number of word endings for the node
    NodeData[Root->GetAddr()] = Val;
    NodeEnds[Root->GetAddr()] = Root->GetNumEnds();

    // Now do the children
    for(Itc = Root->ChildBegin(); Itc != Root->ChildEnd(); ++Itc)
    {
        CreateArrays(Itc->second, StrSet, ChildAddrs, NodeData, NodeEnds);
    }
}

/**********************************************************************************
 * Output the data as a binary file.
 */
static int OutputBinary(ostream *Out, const string & ChkFile, const string & CharSet, StringIntSet_t & StrSet, //NodeSPtr & Root,
                        StringOfInts & ChildAddrs, Uint64Vect & NodeData, UintVect & NodeEnds, StringIntVect_t & Ranks)
{
    int OutputSize;
    unsigned int FewEndStart = 2000000000;
    unsigned int i;
    unsigned int Index;
    unsigned short u;
    TrieCheck h;

    for(Index = 0; Index < NodeData.size(); ++Index)
    {
        uint64_t v = NodeData[Index];
        if ((FewEndStart >= 2000000000) && !(v & (uint64_t(1) << SHIFT_LARGE_ENDING_BIT)))
        {
            FewEndStart = Index;
            break;
        }
    }
    // Header words
    unsigned int NumWordEnd;
    const unsigned int MAGIC = 'z' + ('x'<< 8) + ('c' << 16) + ('v' << 24);
    Out->write((char *)&MAGIC, sizeof MAGIC);   // Write magic
    h(&MAGIC, sizeof MAGIC);
    OutputSize = sizeof MAGIC;

    i = NodeData.size();
    Out->write((char *)&i, sizeof i);   // Write number of nodes
    h(&i, sizeof i);
    OutputSize += sizeof i;

    i = ChildAddrs.size();
    if (NodeData.size() > numeric_limits<unsigned int>::max())
        i |= 1<<31;
    Out->write((char *)&i, sizeof i);   // Write number of child location entries & size of each entry
    h(&i, sizeof i);
    OutputSize += sizeof i;

    i = Ranks.size();
    Out->write((char *)&i, sizeof i);   // Write number of ranks
    h(&i, sizeof i);
    OutputSize += sizeof i;

    NumWordEnd = (NodeData.size() + 7) / 8;
    Out->write((char *)&NumWordEnd, sizeof NumWordEnd);   // Write number of word endings
    h(&NumWordEnd, sizeof NumWordEnd);
    OutputSize += sizeof NumWordEnd;

    i = StrSet.size();
    Out->write((char *)&i, sizeof i);   // Write size of of child bitmap data
    h(&i, sizeof i);
    OutputSize += sizeof i;

    unsigned int BytePerEntry = (CharSet.length() + 7) / 8;
    Out->write((char *)&BytePerEntry, sizeof BytePerEntry);   // Write size of each child bitmap
    h(&BytePerEntry, sizeof BytePerEntry);
    OutputSize += sizeof BytePerEntry;

    Out->write((char *)&FewEndStart, sizeof FewEndStart);   // Write number of large end counts
    h(&FewEndStart, sizeof FewEndStart);
    OutputSize += sizeof FewEndStart;

    i = NodeData.size();
    Out->write((char *)&i, sizeof i);   // Write number of end counts
    h(&i, sizeof i);
    OutputSize += sizeof i;

    i = CharSet.length();
    Out->write((char *)&i, sizeof i);   // Write size of character set
    h(&i, sizeof i);
    OutputSize += sizeof i;

    // Output array of node data
    unsigned char *WordEnds = new unsigned char[NumWordEnd];
    unsigned char v = 0;
    unsigned int z = 0;
    int y = 0;
    for(Index = 0; Index < NodeData.size(); ++Index)
    {
        i = NodeData[Index];
        Out->write((char *)&i, sizeof i);
        h(&i, sizeof i);

        if (NodeData[Index] & (uint64_t(1) << SHIFT_WORD_ENDING_BIT))
            v |= 1 << y;
        if (++y >= 8)
        {
            WordEnds[z++] = v;
            y = 0;
            v = 0;
        }
    }
    while(z < NumWordEnd)
    {
         WordEnds[z++] = v;
         v = 0;
    }
    OutputSize += Index * sizeof i;

    // Output array of node pointers
    for(Index = 0; Index < ChildAddrs.size(); ++Index)
    {
        i = ChildAddrs[Index];
        Out->write((char *)&i, sizeof i);
        h(&i, sizeof i);
    }
    OutputSize += Index * sizeof i;

    // Output ranks
    for(Index = 0; Index < Ranks.size(); ++Index)
    {
        i = Ranks[Index].i;
        if (i >= (1 << 15))
        {
            i -= 1 << 15;
            i /= 4;
            if (i >= (1 << 15))
                i = (1 << 15) - 1;
            i |= 1 << 15;
        }
        if (i > numeric_limits<unsigned short>::max())
            i = numeric_limits<unsigned short>::max();
        u = i;
        Out->write((char *)&u, sizeof u);
        h(&u, sizeof u);
    }
    OutputSize += Index * sizeof u;

    // Output word end bit markers
    Out->write((char *)WordEnds, NumWordEnd);
    h(WordEnds, NumWordEnd);
    OutputSize += NumWordEnd;
    delete WordEnds;

    StringIntSet_t::iterator Its;
    string Str;
    unsigned char Buf[8];

    // Get the items from StrSet ordered by the index
    StrIntPtrVect_t SetPtrs;
    SetPtrs.resize(StrSet.size());
    for(Its = StrSet.begin(); Its != StrSet.end(); ++Its)
    {
        StringInt *p = Its->Self();
        if (p->i >= StrSet.size())
            throw "Bad index";
        SetPtrs[p->i] = p;
    }
    // Output child bitmap
    for(Index = 0; Index < SetPtrs.size(); ++Index)
    {
        string::size_type z, y;
        StringInt *p;
        memset(Buf, 0, sizeof Buf);
        p = SetPtrs[Index];
        Str = p->s;
        for(z = 0; z < Str.length(); ++z)
        {
            y = CharSet.find(Str[z]);
            if (y != string::npos)
            {
                Buf[y/8] |= 1 << (y & 7);
            }
        }
        Out->write((char *)Buf, BytePerEntry);
        h(Buf, BytePerEntry);
     }
    OutputSize += Index * BytePerEntry;

    unsigned char c;
    for(Index = 0; Index < FewEndStart; ++Index)
    {
        i = NodeEnds[Index] >> 8;
        if (i >= 256)
            c = 0;
        else
            c = i;
        Out->write((char *)&c, 1);
        h(&c, 1);
    }
    OutputSize += Index * sizeof c;

    for(Index = 0; Index < NodeEnds.size(); ++Index)
    {
        c = NodeEnds[Index];
        Out->write((char *)&c, 1);
        h(&c, 1);
    }
    OutputSize += Index * sizeof c;

    Out->write(CharSet.c_str(), CharSet.length());
    h(CharSet.c_str(), CharSet.length());
    OutputSize += CharSet.length();

    if (!ChkFile.empty())
    {
        // Write the checksum file
        TrieCheck::Check_t x = h.Result();
        ofstream f(ChkFile);
        f << "static const unsigned char WordCheck[" << sizeof x << "] =\n{\n    ";
        unsigned char *c = reinterpret_cast<unsigned char *>(&x);
        for(Index = 0; Index < sizeof x; ++Index, ++c)
        {
            if (Index)
                f << ',';
            f << int(*c);
        }
        f << "\n};\n";
        f << "#define WORD_FILE_SIZE " << OutputSize << endl;
        f << "#define ROOT_NODE_LOC 0\n"
             "#define BITS_CHILD_PATT_INDEX " << BITS_CHILD_PATT_INDEX << "\n"
             "#define BITS_CHILD_MAP_INDEX  " << BITS_CHILD_MAP_INDEX << "\n" 
             "#define SHIFT_CHILD_MAP_INDEX BITS_CHILD_PATT_INDEX\n"
             "#define SHIFT_WORD_ENDING_BIT (SHIFT_CHILD_MAP_INDEX + BITS_CHILD_MAP_INDEX)" << endl;
        f.close();
    }
    return OutputSize;
}

int OutputTester(ostream *Out, bool /*Cmnts*/, StringIntVect_t & Ranks)
{
    unsigned int Index;
    string Pwd;
    for(Index = 01; Index < Ranks.size(); ++Index)
    {
        unsigned int v = Ranks[Index].i;
        Pwd = Ranks[Index].s;
        string::size_type x = Pwd.find(':');
        if (x != string::npos)
            Pwd.erase(0, x+1);

        *Out << Pwd.c_str() << "  ";
        for(x = Pwd.length(); x < 16; ++x)
            *Out << ' ';
        *Out << log(v*1.0) / log(2.0) << "  " << v << '\n';
    }
    return Index;
}
const int LINE_OUT_LEN = 160;
/**********************************************************************************
 * Output the data as C source.
 */
int OutputCode(ostream *Out, bool Cmnts, const string & CharSet, StringIntSet_t & StrSet, NodeSPtr & Root,
               StringOfInts & ChildAddrs, Uint64Vect & NodeData, UintVect & NodeEnds, StringIntVect_t & Ranks)
{
    unsigned int Index;
    int OutputSize;

    if (Cmnts)
        *Out << "#define ND(e,c,b) (c<<" << SHIFT_CHILD_MAP_INDEX << ")|b\n";

    // Output array of node data
    *Out << "#define ROOT_NODE_LOC 0\n"
            "#define BITS_CHILD_PATT_INDEX " << BITS_CHILD_PATT_INDEX << "\n"
            "#define BITS_CHILD_MAP_INDEX  " << BITS_CHILD_MAP_INDEX << "\n" 
            "#define SHIFT_CHILD_MAP_INDEX BITS_CHILD_PATT_INDEX\n"
            "#define SHIFT_WORD_ENDING_BIT (SHIFT_CHILD_MAP_INDEX + BITS_CHILD_MAP_INDEX)\n"
            "static const unsigned int DictNodes[" << NodeData.size() << "] =\n{";
    OutputSize = NodeData.size() * sizeof(unsigned int);
    int x = 999;
    unsigned int FewEndStart = 2000000000;
    for(Index = 0; Index < NodeData.size(); ++Index)
    {
        uint64_t v;
        x += 11;
        if (x > LINE_OUT_LEN)
        {
            *Out << "\n    ";
            x=0;
        }
        v = NodeData[Index];
        v &= (uint64_t(1) << SHIFT_WORD_ENDING_BIT) - 1;
        if (Cmnts)
        {
            uint64_t i;
            i = (v >> SHIFT_WORD_ENDING_BIT) & 3;
            *Out << "ND(" << i << ',';
            i= (v >> SHIFT_CHILD_MAP_INDEX) & ((1<<BITS_CHILD_MAP_INDEX)-1);
            *Out << i << ',';
            if (i < 10000) *Out << ' ';
            if (i < 1000)  *Out << ' ';
            if (i < 100)   *Out << ' ';
            if (i < 10)    *Out << ' ';
            i = v & ((1<<BITS_CHILD_PATT_INDEX)-1);
            *Out << i << ")";
            if (Index < (NodeData.size()-1))
            {
                *Out << ',';
                if (i < 1000)  *Out << ' ';
                if (i < 100)   *Out << ' ';
                if (i < 10)    *Out << ' ';
            }
        }
        else
        {
            *Out << v;
            if (Index < (NodeData.size()-1))
            {
                *Out << ',';
                if (v < 1000000000) *Out << ' ';
                if (v < 100000000) *Out << ' ';
                if (v < 10000000) *Out << ' ';
                if (v < 1000000) *Out << ' ';
                if (v < 100000) *Out << ' ';
                if (v < 10000) *Out << ' ';
                if (v < 1000)  *Out << ' ';
                if (v < 100)   *Out << ' ';
                if (v < 10)    *Out << ' ';
            }
        }
        if ((FewEndStart >= 2000000000) && !(NodeData[Index] & (uint64_t(1) << SHIFT_LARGE_ENDING_BIT)))
            FewEndStart = Index;
    }
    *Out << "\n};\n";
    unsigned int Len = ((NodeData.size() + 7) / 8);
    OutputSize += Len;
    x = 999;
    *Out << "static unsigned char WordEndBits[" << Len << "] =\n{";
    Index = 0;
    unsigned int v = 0;
    unsigned int y = 0;
    unsigned int z = 0;
    while(z < Len)
    {
        if (Index < NodeData.size())
        {
            if (NodeData[Index] & (uint64_t(1) << SHIFT_WORD_ENDING_BIT))
                v |= 1 << y;
        }
        if (++y >= 8)
        {
            x += 4;
            if (x > LINE_OUT_LEN)
            {
                *Out << "\n    ";
                x = 0;
            }
            *Out << v;
            if (++z < Len)
            {
                *Out << ',';
                if (v < 100) *Out << ' ';
                if (v < 10) *Out << ' ';
            }
            y = 0;
            v = 0;
        }
        ++Index;
    }
    *Out << "\n};\n";
    // Output array of node pointers
    *Out << "static const unsigned ";
    if (NodeData.size() > numeric_limits<unsigned short>::max())
    {
        *Out << "int";
        x = sizeof(unsigned int);
    }
    else
    {
        *Out << "short";
        x = sizeof(unsigned short);
    }
    *Out << " ChildLocs[" << ChildAddrs.size() << "] =\n{";
    OutputSize += x * ChildAddrs.size();
    x = 999;
    for(Index = 0; Index < ChildAddrs.size(); ++Index)
    {
        int v;
        x += 6;
        if (x > LINE_OUT_LEN)
        {
            *Out << "\n    ";
            x=0;
        }
        v = ChildAddrs[Index];
        *Out << v;
        if (Index < (ChildAddrs.size()-1))
        {
            *Out << ',';
            if (v < 10000) *Out << ' ';
            if (v < 1000)  *Out << ' ';
            if (v < 100)   *Out << ' ';
            if (v < 10)    *Out << ' ';
        }
    }
    *Out << "\n};\n";

    // Output the rank of the words
    *Out << "static const unsigned short Ranks[" << Ranks.size() << "] =\n{";
    OutputSize += Ranks.size() * sizeof(unsigned short);
    x = 999;
    bool TooBig = false;
    if (Cmnts)
    {
        *Out << "\n";
        for(Index = 0; Index < Ranks.size(); ++Index)
        {
            unsigned int v;
            *Out << "    ";
            v = Ranks[Index].i;
            if (v >= (1 << 15))
            {
                v -= 1 << 15;
                v /= 4;
                if (v >= (1 << 15))
                {
                    TooBig = true;
                    v = (1 << 15) - 1;
                }
                v |= 1 << 15;
            }
            if (v > numeric_limits<unsigned short>::max())
                v = numeric_limits<unsigned short>::max();
            *Out << v;
            if (Index < (Ranks.size()-1))
            {
                *Out << ',';
                if (v < 10000) *Out << ' ';
                if (v < 1000)  *Out << ' ';
                if (v < 100)   *Out << ' ';
                if (v < 10)    *Out << ' ';
            }
            *Out << " // " << Ranks[Index].s.c_str() << '\n';
        }
    }
    else
    {
        for(Index = 0; Index < Ranks.size(); ++Index)
        {
            unsigned int v;
            x += 6;
            if (x > LINE_OUT_LEN)
            {
                *Out << "\n    ";
                x=0;
            }
            v = Ranks[Index].i;
            if (v >= (1 << 15))
            {
                v -= 1 << 15;
                v /= 4;
                if (v >= (1<<15))
                {
                    TooBig = true;
                    v = (1 << 15) - 1;
                }
                v |= 1 << 15;
            }
            if (v > numeric_limits<unsigned short>::max())
                v = numeric_limits<unsigned short>::max();
            *Out << v;
            if (Index < (Ranks.size()-1))
            {
                *Out << ',';
                if (v < 10000) *Out << ' ';
                if (v < 1000)  *Out << ' ';
                if (v < 100)   *Out << ' ';
                if (v < 10)    *Out << ' ';
            }
        }
    }
    *Out << "\n};\n";
    if (TooBig)
    {
        unsigned int v  = ((1<<15) - 1) * 4 + (1<<15);
        cout << "// Word ranks too large, value restricted to " << v << endl;
    }
    unsigned int BytePerEntry = (CharSet.length() + 7) / 8;
    *Out << "#define SizeChildMapEntry " << BytePerEntry << '\n';
    *Out << "static const unsigned char ChildMap[" << StrSet.size() << '*' << BytePerEntry << "] =\n{";
    OutputSize += StrSet.size() * BytePerEntry * sizeof(unsigned char);

    StringIntSet_t::iterator Its;
    string Str;
    unsigned char Buf[8];

    // Get the items from StrSet ordered by the index
    StrIntPtrVect_t SetPtrs;
    SetPtrs.resize(StrSet.size());
    for(Its = StrSet.begin(); Its != StrSet.end(); ++Its)
    {
        StringInt *p = Its->Self();
        if (p->i >= StrSet.size())
        {
            cout << "p->i=" << p->i << "  " << p->s.c_str() << endl;
            throw "Bad index";
        }
        SetPtrs[p->i] = p;
    }
    x = 999;
    for(Index = 0; Index < SetPtrs.size(); ++Index)
    {
        string::size_type z, y;
        StringInt *p;
        memset(Buf, 0, sizeof Buf);
        if (x > LINE_OUT_LEN)
        {
            *Out << "\n    ";
            x = 4*BytePerEntry;
        }
        p = SetPtrs[Index];
        Str = p->s;
        for(z = 0; z < Str.length(); ++z)
        {
            y = CharSet.find(Str[z]);
            if (y != string::npos)
            {
                Buf[y/8] |= 1 << (y & 7);
            }
        }
        for(z = 0; z < BytePerEntry; ++z)
        {
            y = Buf[z] & 0xFF;
            *Out << y;
            if (z < (BytePerEntry-1))
                *Out << ',';
            else
            {
                if (Index < (SetPtrs.size() - 1))
                    *Out << ", ";
            }
            if (y < 100)
                *Out << ' ';
            if (y < 10)
                *Out << ' ';
            x += 4;
        }
        if (Cmnts)
        {
            *Out << " // " << p->i << ": " << Str;
            x = 999;
        }
    }
    *Out << "\n};" << endl;

    // Output the top 8 bits of the node word endings count. Since node with >255 endings have
    // been placed at the begining, and ther are not too many of them the array is fairly small.
    *Out << "#define NumLargeCounts " << FewEndStart << "\n";
    *Out << "static const unsigned char EndCountLge[" << FewEndStart << "] =\n{";
    OutputSize += FewEndStart * sizeof(unsigned char);
    x = 999;
    for(Index = 0; Index < FewEndStart; ++Index)
    {
        unsigned int v;
        x += 4;
        if (x > LINE_OUT_LEN)
        {
            *Out << "\n    ";
            x=0;
        }
        v = NodeEnds[Index] >> 8;
        if (v >= 256)
            v = 0;
        *Out << v;
        if (Index < (FewEndStart-1))
        {
            *Out << ',';
            if (v < 100)   *Out << ' ';
            if (v < 10)    *Out << ' ';
        }
    }
    *Out << "\n};\n";

    // Output all the word ending counts. For the first few nodes this is just the lower 8 bits of
    // the value. For the rest each entry contains the whole count. The split between lower and
    // upper halves of the value for the first few nodes allows bytes arrays to be used, so saving
    // memory.
    *Out << "static const unsigned char EndCountSml[" << NodeEnds.size() << "] =\n{";
    OutputSize += NodeEnds.size() * sizeof(unsigned char);
    x = 999;
    for(Index = 0; Index < NodeEnds.size(); ++Index)
    {
        unsigned int v;
        x += 4;
        if (x > LINE_OUT_LEN)
        {
            *Out << "\n    ";
            x=0;
        }
        v = NodeEnds[Index] & 255;
        *Out << v;
        if (Index < (NodeEnds.size()-1))
        {
            *Out << ',';
            if (v < 100)   *Out << ' ';
            if (v < 10)    *Out << ' ';
        }
    }
    *Out << "\n};\n";

    // Finally output the used characters.
    *Out << "static const char CharSet[" << CharSet.length()+1 << "] = \"";
    OutputSize += CharSet.length() * sizeof(char);
    for(Index = 0; Index < CharSet.length(); ++Index)
    {
        char c = CharSet[Index];
        if ((c == '\\') || (c == '"'))
            *Out << '\\';
        *Out << c;
    }
    *Out << "\";" << endl;
    *Out << "#define ROOT_NODE_LOC " << Root->GetAddr() << "\n";
    return OutputSize + sizeof(unsigned int);
}
enum { OUT_C_CODE, OUT_BINARY, OUT_TESTER };
/**********************************************************************************
 */
int main(int argc, char *argv[])
{
    int i;
    int MaxRank = 999999999;
    int OutType = OUT_C_CODE;
    bool Verbose = false;
    bool Comments = false;
    string FileName, HashFile;
    char *OutFile = 0;
    EntryMap_t Entries;
    FileInfo InInfo[10];
    int NumFiles = 0;
    MinLength = 999;

    try
    {
        for(i = 1; i < argc; ++i)
        {
            FileName = argv[i];
            if (FileName == "-b")
            {
                // Output a binary file to stdout or file
                OutType = OUT_BINARY;
                continue;
            }
            if (FileName == "-t")
            {
                // Output a tester file to stdout or file
                OutType = OUT_TESTER;
                continue;
            }
            if (FileName == "-c")
            {
                // Add comments to the output (if text)
                Comments = true;
                continue;
            }
            if (FileName == "-o")
            {
                // Give output file
                if (++i < argc)
                    OutFile = argv[i];
                continue;
            }
            if (FileName == "-h")
            {
                // Give crc header output file
                if (++i < argc)
                    HashFile = argv[i];
                continue;
            }
            if (FileName == "-r")
            {
                // Ignore words with too high rank
                if (++i < argc)
                {
                    char *p=0;
                    MaxRank = strtol(argv[i], &p, 0);
                    if ((MaxRank < 1000) || *p)
                        MaxRank = 999999999;
                    continue;
                }
            }
            if (FileName == "-v")
            {
                Verbose = true;
                continue;
            }
            if (FileName[0] == '-')
            {
                cerr << "Usage: " << argv[0] << " [ -c ] [ -b | -t ] [ -o Ofile ] [ -h Hfile ] Files...\n"
                        "Where:\n"
                        "     -b        Generate a binary output file\n"
                        "     -t        Generate a test file for testing zxcvbn\n"
                        "     -c        Add comments to output file if C code mode\n"
                        "     -r number Ignore words with rank greater than number (must be >=1000)\n"
                        "     -v        Additional information output\n"
                        "     -h Hfile  Write file checksum to file Hfile as C code (for -b mode)\n"
                        "     -o Ofile  Write output to file Ofile\n"
                        "     Files     The dictionary input files to read\n"
                        "  If the -o option is not used, output is written to stdout\n"
                        "  if the -b option is not used, output is in the form of C source code\n"
                        << endl;
                return 1;
            }
            ReadInputFile(FileName, InInfo[NumFiles], MaxRank);
            if (NumFiles < int(sizeof InInfo / sizeof InInfo[0] - 1))
                ++NumFiles;
        }
        CombineWordLists(Entries, InInfo, NumFiles);
        if (Verbose)
        {
            if (!OutFile && (OutType == OUT_C_CODE))
                cout << "/*\n";
            for(i = 0; i < NumFiles; ++i)
            {
                FileInfo *Fi = InInfo + i;
                cout << "Read input file " << Fi->Name << endl;
                cout << "   Input words  " << Fi->Words << endl;
                cout << "   Used words   " << Fi->Used << endl;
                cout << "        Unused  " << Fi->BruteIgnore <<
                        " Bruteforce compare, " << Fi->Accented <<
                        " Accented char, " << Fi->Dups << " Duplicates" << endl;
            }
        }
        bool InputCharSet[256];
        NodeSPtr Root(new Node);
        // Initially charset of used chracters is empty
        memset(InputCharSet, 0, sizeof InputCharSet);

        // Add words to the trie with root in Root
        ProcessEntries(Root, Entries, InputCharSet);

        // Get some interesting info
        int NumEnds = Root->CalcEndings();
        int Hi = Root->CalcHeight();
        int NumNodes = Root->NodeCount();
        if (Verbose)
        {
            cout << "Max word length = " << MaxLength << endl;
            cout << "Min word length = " << MinLength << endl;
            cout << "Num input chars = " << NumChars << endl;
            cout << "Num input words = " << NumInWords << endl;
            cout << "Duplicate words = " << NumDuplicate;
            cout << "Number of Ends  = " << NumEnds << endl;
            cout << "Number of Nodes = " << NumNodes << endl;
            cout << "Trie height = " << Hi << endl;
        }
        // Store the alphabetical ordering of the input words
        i = 0;
        ScanTrieForOrder(Entries, i, Root, string());
        if (Verbose)
            cout << "Trie Order = " << i << endl;
        int InputOrder = i;
        // Reduce the Trie
        ReduceTrie(Root);

        // Output some interesting information
        NumNodes = Root->NodeCount();
        int ReduceEnds = Root->CalcEndings();
        if (Verbose)
        {
            cout << "After reduce:\n";
            cout << "Number of Ends  = " << ReduceEnds << endl;
            cout << "Number of Nodes = " << NumNodes << endl;
        }
        // Check reduction was OK
        StringIntVect_t Ranks;
        int CheckEnds = CheckReduction(Ranks, Root, Entries);
        if (Verbose)
            cout << "Number of Words = " << CheckEnds << endl;

        ChkNum Tst = CheckEntries(Root, string(), Entries);
        if (Verbose)
        {
            cout << "2nd check - Number of valid words = " << Tst.Match << endl;
            cout << "          Number of invalid words = " << Tst.Err << endl;
        }

        // Give up if there was an error
        if (Tst.Err)
            throw "Checks show invalid words after reduction";
        if ((Tst.Match != InputOrder) || (ReduceEnds != InputOrder))
            throw "Word count changed after reduce";

        // Output more info
        StringIntSet_t ChildBits;
        string CharSet = MakeCharSet(InputCharSet);
        if (Verbose)
            cout << "Used characters (" << CharSet.length() << "): " << CharSet.c_str() << endl;

        // Make a set of all unique child character patterns for the nodes
        i=0;
        Root->ClearCounted();
        MakeChildBitMap(ChildBits, Root, i);
        if (Verbose)
            cout << "Number of child bitmaps = " << ChildBits.size() << endl;

        // Get final node address
        Root->CalcAddress();

        Uint64Vect NodeData;
        UintVect NodeEnds;
        StringOfInts ChildAddrs;

        // Resize to save library adjusting allocation during data creation
        NodeData.resize(NumNodes, 4000000000);
        NodeEnds.resize(NumNodes, 4000000000);
        CreateArrays(Root, ChildBits, ChildAddrs, NodeData, NodeEnds);
        if (Verbose)
        {
            cout << "Node data array size " << NodeData.size() << endl;
            cout << "Child pointer array size " << ChildAddrs.size() << endl;
        }
        shared_ptr<ofstream> fout;
        ostream *Out = &cout;
        if (OutFile)
        {
            fout = shared_ptr<ofstream>(new ofstream);
            if (OutType == OUT_BINARY)
                fout->open(OutFile, ios_base::trunc | ios_base::binary);
            else
                fout->open(OutFile, ios_base::trunc);
            Out = fout.get();
        }
        if (!OutFile && (OutType == OUT_C_CODE))
            cout << "*/\n";

        if (OutType == OUT_BINARY)
            i = OutputBinary(Out, HashFile, CharSet, ChildBits, ChildAddrs, NodeData, NodeEnds, Ranks);
        else if (OutType == OUT_TESTER)
            i = OutputTester(Out, Comments, Ranks);
        else
            i = OutputCode(Out, Comments, CharSet, ChildBits, Root, ChildAddrs, NodeData, NodeEnds, Ranks);

        if (fout)
        {
            fout->close();
        }
    }
    catch(const char *m)
    {
        cerr << m << endl;
        return 1;
    }
    catch(string m)
    {
        cerr << m.c_str() << endl;
        return 1;
    }
    catch(...)
    {
        cerr << "Unhandled exception" << endl;
        return 1;
    }
    return 0;
}

/**********************************************************************************/
