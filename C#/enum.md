# C#枚举最优雅的用法

  public enum AbilityLevel
    {
        /// <summary>
        /// Indicates that the individual has a general knowledge to a certain technology, it is the lowest level.
        /// </summary>
        [Description("入门")]
        General = 1,

        /// <summary>
        /// Indicates that the individual comprehends a certain technology.
        /// </summary>
        [Description("了解")]
        Comprehend = 2,

        /// <summary>
        /// Indicates that the individual has a pratical knowledge to a certain technology.
        /// </summary>
        [Description("一般")]
        Pratical = 3,

        /// <summary>
        /// Indicates that the individual is very skillful to a certain technology.
        /// </summary>
        [Description("良好")]
        Skilled = 4,

        /// <summary>
        /// Indicates that the individual has a great knowledge and masters a certain technology, it is the highest level.
        /// </summary>
        [Description("精通")]
        Master = 5
    }
拓展方法，或者说是重写ToString()方法

/// <summary>
    /// Provides globalization for <see cref="AbilityLevel"/> enum.
    /// </summary>
    public static class AbilityLevelValue
    {
        /// <summary>
        /// Gets the culture specified string value of <see cref="AbilityLevel"/>.
        /// </summary>
        /// <param name="level">The value of <see cref="AbilityLevel"/>.</param>
        /// <param name="cultureName">The short name of culture.</param>
        /// <returns>Culture specified string value of <paramref name="level"/></returns>
        public static string ToLocalString(this AbilityLevel level, string cultureName="zh-cn")
        {
            if (cultureName == "zh-cn")
            {
                switch (level)
                {
                    case AbilityLevel.General:
                        return "入门";
                    case AbilityLevel.Comprehend:
                        return "了解";
                    case AbilityLevel.Pratical:
                        return "一般";
                    case AbilityLevel.Skilled:
                        return "良好";
                    case AbilityLevel.Master:
                        return "精通";
                    default:
                        throw new ArgumentException(
                            "Invalid AbilityLevel value...", "level");
                }
            }
            else
            {
                return level.ToString();
            }
        }
    }
获取特性，自定义了一个枚举的拓展方法

  /// <summary>
    /// 枚举拓展类
    /// </summary>
    public static  class EnumExt
    {
        public static string  GetEnumDescription( this System.Enum enumObj)
        {
            System.Reflection.FieldInfo fieldInfo = enumObj.GetType().GetField(enumObj.ToString());

            object[] attribArray = fieldInfo.GetCustomAttributes(false);
            if (attribArray.Length == 0)
            {
                return String.Empty;
            }
            else
            {
                var attrib = attribArray[0] as DescriptionAttribute;

                return attrib.Description;
            }
        }
    }
重点在下边

       public static SelectList ToSelectList<TEnum>(this TEnum enumObj, Func<TEnum, string> getDesc)
        {
            var values = from TEnum e in Enum.GetValues(typeof(TEnum))
                         where getDesc(e) != null
                         select new { ID = e, Name = getDesc(e) };

            return new SelectList(values, "ID", "Name", enumObj);
        }
用法在这里

        <p>
            <label>公司性质<em>*</em>：</label>
            @Html.DropDownListFor(m => m.LegalStatus,
                  Model.LegalStatus.ToSelectList(e => e.GetEnumDescription()),
                    new { @class = "default" })
            @Html.ValidationMessageFor(m => m.LegalStatus)
        </p>
运行结果



### source
 https://www.cnblogs.com/qulianqing/p/7162706.html